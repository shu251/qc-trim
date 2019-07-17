# Input raw fastq files, QC, and perform trimming
configfile: "config.yaml"

import io 
import os
import pandas as pd
import pathlib
from snakemake.exceptions import print_exception, WorkflowError

#----SET VARIABLES----#

#PROJ = config["proj_name"]
INPUTDIR = config["raw_data"]
SCRATCH = config["scratch"]
OUTPUTDIR = config["outputDIR"]

# Use glob statement to find all samples in 'raw_data' directory
SAMPLE_LIST,NUMS = glob_wildcards("INPUTDIR/{sample}_{num}.fastq.gz")
# Unique the output variables from glob_wildcards
SAMPLE_SET = set(SAMPLE_LIST)
SET_NUMS = set(NUMS)

#----DEFINE RULES----#

rule all:
  input:
    # fastqc output before trimming
    html = expand("{scratch}/fastqc/{sample}_{num}_fastqc.html", scratch = SCRATCH, sample=SAMPLE_SET, num=SET_NUMS),
    zip = expand("{scratch}/fastqc/{sample}_{num}_fastqc.zip", scratch = SCRATCH, sample=SAMPLE_SET, num=SET_NUMS),
    orig_html = SCRATCH + "/fastqc/raw_multiqc.html",
    orig_stats = SCRATCH + "/fastqc/raw_multiqc_general_stats.txt",
    # Trimmed data output
    trimmedData = expand("{scratch}/trimmed/{sample}_{num}_trim.fastq.gz", scratch= SCRATCH, sample=SAMPLE_SET, num=SET_NUMS), 
    html_trim = expand("{scratch}/fastqc/{sample}_{num}_trimmed_fastqc.html", scratch= SCRATCH, sample=SAMPLE_SET, num=SET_NUMS),
    zip_trim = expand("{scratch}/fastqc/{sample}_{num}_trimmed_fastqc.zip", scratch= SCRATCH, sample=SAMPLE_SET, num=SET_NUMS),
    trim_html = SCRATCH + "/fastqc/trimmed_multiqc.html", #next change to include proj name
    trim_stats = SCRATCH + "/fastqc/trimmed_multiqc_general_stats.txt",

rule fastqc:
  input:    
    INPUTDIR + "/{sample}_{num}.fastq.gz"
  output:
    html = SCRATCH + "/fastqc/{sample}_{num}_fastqc.html",
    zip = SCRATCH + "/fastqc/{sample}_{num}_fastqc.zip"
  params: ""
  log:
    SCRATCH + "/logs/fastqc/{sample}_{num}.log"
  wrapper:
    "0.35.2/bio/fastqc"

rule trimmomatic_pe:
  input:
    r1 = INPUTDIR + "/{sample}_1.fastq.gz",
    r2 = INPUTDIR + "/{sample}_2.fastq.gz"
  output:
    r1 = SCRATCH + "/trimmed/{sample}_1_trim.fastq.gz",
    r2 = SCRATCH + "/trimmed/{sample}_2_trim.fastq.gz",
    # reads where trimming entirely removed the mate
    r1_unpaired = SCRATCH + "/trimmed/{sample}_1.unpaired.fastq.gz",
    r2_unpaired = SCRATCH + "/trimmed/{sample}_2.unpaired.fastq.gz"
  log:
    SCRATCH + "/trimmed/logs/trimmomatic/{sample}.log"
  params:
    trimmer = ["LEADING:2", "TRAILING:2", "SLIDINGWINDOW:4:2", "MINLEN:25"],
    extra = ""
  wrapper:
    "0.35.2/bio/trimmomatic/pe"

rule fastqc_trim:
  input:
    SCRATCH + "/trimmed/{sample}_{num}_trim.fastq.gz"
  output:
    html = SCRATCH + "/fastqc/{sample}_{num}_trimmed_fastqc.html",
    zip = SCRATCH + "/fastqc/{sample}_{num}_trimmed_fastqc.zip"
  params: ""
  log:
    SCRATCH + "/logs/fastqc/{sample}_{num}_trimmed.log"
  wrapper:
    "0.35.2/bio/fastqc"

rule multiqc:
  input:
    orig = expand("{scratch}/fastqc/{sample}_{num}_fastqc.zip", scratch= SCRATCH, sample=SAMPLE_SET, num=SET_NUMS),
    trimmed = expand("{scratch}/fastqc/{sample}_{num}_trimmed_fastqc.zip", scratch= SCRATCH, sample=SAMPLE_SET, num=SET_NUMS)
  output:
    orig_html = SCRATCH + "/fastqc/raw_multiqc.html", 
    orig_stats = SCRATCH + "/fastqc/raw_multiqc_general_stats.txt",
    trim_html = SCRATCH + "/fastqc/trimmed_multiqc.html", 
    trim_stats = SCRATCH + "/fastqc/trimmed_multiqc_general_stats.txt"
  conda:
   "envs/multiqc-env.yaml"
  shell: 
    """
    multiqc -n multiqc.html {input.orig} #run multiqc
    mv multiqc.html {output.orig_html} #rename html
    mv multiqc_data/multiqc_general_stats.txt {output.orig_stats} #move and rename stats
    rm -rf multiqc_data #clean-up
    #repeat for trimmed data
    multiqc -n multiqc.html {input.trimmed} #run multiqc
    mv multiqc.html {output.trim_html} #rename html
    mv multiqc_data/multiqc_general_stats.txt {output.trim_stats} #move and rename stats
    rm -rf multiqc_data	#clean-up
    """
