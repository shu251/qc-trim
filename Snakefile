# Input raw fastq files, QC, and perform trimming
configfile: "config.yaml"

import io 
import os
import pandas as pd
import pathlib
from snakemake.exceptions import print_exception, WorkflowError

#----SET VARIABLES----#

PROJ = config["proj_name"]
INPUTDIR = config["raw_data"]
SCRATCH = config["scratch"]
SCRATCH_PROJ = os.path.join(SCRATCH, PROJ)
OUTPUTDIR = config["outputDIR"]

# Use glob statement to find all samples in 'raw_data' directory
SAMPLE_LIST,NUMS = glob_wildcards(INPUTDIR + "/{sample}_{num}.fastq.gz")
# Unique the output variables from glob_wildcards
SAMPLE_SET = set(SAMPLE_LIST)
SET_NUMS = set(NUMS)

#----DEFINE RULES----#

rule all:
  input:
    # fastqc output before trimming
    html = expand("{base}/fastqc/{sample}_{num}_fastqc.html", base = SCRATCH_PROJ, sample=SAMPLE_SET, num=SET_NUMS),
    zip = expand("{base}/fastqc/{sample}_{num}_fastqc.zip", base = SCRATCH_PROJ, sample=SAMPLE_SET, num=SET_NUMS),
    # Trimmed data output
    trimmedData = expand("{base}/trimmed/{sample}_{num}_trim.fastq.gz", base = SCRATCH_PROJ, sample=SAMPLE_SET, num=SET_NUMS), 
    html_trim = expand("{base}/fastqc/{sample}_{num}_trimmed_fastqc.html", base = SCRATCH_PROJ, sample=SAMPLE_SET, num=SET_NUMS),
    zip_trim = expand("{base}/fastqc/{sample}_{num}_trimmed_fastqc.zip", base = SCRATCH_PROJ, sample=SAMPLE_SET, num=SET_NUMS),

rule fastqc:
  input:    
    INPUTDIR + "/{sample}_{num}.fastq.gz"
  output:
    html = SCRATCH_PROJ + "/fastqc/{sample}_{num}_fastqc.html",
    zip = SCRATCH_PROJ + "/fastqc/{sample}_{num}_fastqc.zip"
  params: ""
  log:
    SCRATCH_PROJ + "/logs/fastqc/{sample}_{num}.log"
  wrapper:
    "0.35.2/bio/fastqc"

rule trimmomatic_pe:
  input:
    r1 = INPUTDIR + "/{sample}_1.fastq.gz",
    r2 = INPUTDIR + "/{sample}_2.fastq.gz"
  output:
    r1 = SCRATCH_PROJ + "/trimmed/{sample}_1_trim.fastq.gz",
    r2 = SCRATCH_PROJ + "/trimmed/{sample}_2_trim.fastq.gz",
    # reads where trimming entirely removed the mate
    r1_unpaired = SCRATCH_PROJ + "/trimmed/{sample}_1.unpaired.fastq.gz",
    r2_unpaired = SCRATCH_PROJ + "/trimmed/{sample}_2.unpaired.fastq.gz"
  log:
    SCRATCH_PROJ + "/trimmed/logs/trimmomatic/{sample}.log"
  params:
    trimmer = ["LEADING:2", "TRAILING:2", "SLIDINGWINDOW:4:2", "MINLEN:25"],
    extra = ""
  wrapper:
    "0.35.2/bio/trimmomatic/pe"

rule fastqc_trim:
  input:
    SCRATCH_PROJ + "/trimmed/{sample}_{num}_trim.fastq.gz"
  output:
    html = SCRATCH_PROJ + "/fastqc/{sample}_{num}_trimmed_fastqc.html",
    zip = SCRATCH_PROJ + "/fastqc/{sample}_{num}_trimmed_fastqc.zip"
  params: ""
  log:
    SCRATCH_PROJ + "/logs/fastqc/{sample}_{num}_trimmed.log"
  wrapper:
    "0.35.2/bio/fastqc"
