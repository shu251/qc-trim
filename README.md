## Quality control raw sequence files and trim

## Set up working environment and directory

### _(1) Get this repository and build conda environment_
Requires an installation of Anaconda. To get more familiar with using conda environments, see [this post using conda with R](https://alexanderlabwhoi.github.io/post/anaconda-r-sarah/) or [read about them here](https://docs.conda.io/projects/conda/en/latest/user-guide/tasks/manage-environments.html). The conda environment to run this pipeline was build to run [Snakemake](https://snakemake.readthedocs.io/en/stable/).
```
# clone this repo
git clone https://github.com/shu251/qc-trim.git

# build conda environment to run snakemake
conda env create --name snake-qc --file envs/snake.yaml

# Enter this conda environment
conda activate snake-qc
```

### _(2) Set up your working directory_

To run this pipeline, we need to update the ```config.yaml``` file which will tell the Snakemake pipeline where our raw fastq files are and where we want the output files to be placed.

 Use a text editor like 'nano' or 'tmux' to modify these lines of the config file:
* Move all fastq files to ```qc-trim/raw_data/``` directory **or** change the ```raw_data:``` line in the config file to the full path to your fastq files.
* Since I am working on an HPC I use a scratch space to write output files. Change this scratch line to where your scratch directory is
* Within my scratch directory, the output file will be placed in a new directory of this name. In the example below, all my output files will be placed in the directory ``` /vortexfs1/scratch/sarahhu/test-qc/```. This way my scratch directory will be organized as I run multiple projects.
* Also change the location of where adapters for your study can be found for the trimmomatic step
```
# Change to location of all raw .fastq (or .fastq.gz) files
raw_data: /vortexfs1/omics/huber/shu/qc-trim/raw_data

# Change to output directory (on HPC, use your scratch)
scratch:  /vortexfs1/scratch/sarahhu

# Add a project name, output files will be placed in a directory of this name in scratch
proj_name: test-qc

# Change to output directory to eventually move all trimmed reads to
outputDIR: /vortexfs1/omics/huber/shu/qc-trim

# Location of illumina adapters, full path
adapters: /vortexfs1/omics/huber/db/adapters/illumina-adapters.fa
```

### _(3) Execute dryrun of snakemake pipeline_

```
snakemake -np
# The command 'snakemake' automatically looks for 'Snakefile'
```

### _(4) Execute snakemake_

```
snakemake --use-conda
# The '--use-conda' flag is necessary because we enable fastqc, trimmomatic, and multiqc conda environments
```

### _(5) Run snakemake with SLURM_
[Read about executing snakemake on a cluster](https://snakemake.readthedocs.io/en/stable/executable.html) and another explanation on how to execute with a submit script can be found [here](https://hpc-carpentry.github.io/hpc-python/17-cluster/).    
Review the submit scripts available in ```submitscripts```. Files in this directory include another config file called ```cluster.yaml```, and two scripts to submit your snakemake pipeline to the cluster with and without the dry run option.   
First, open and modify the ```cluster.yaml``` to fit your machine. Then test run using the provided submit scripts.
```
# Make sure you are still in the snake-tagseq conda environment
bash submitscripts/submit-slurm-dry.sh
```
Outputs should all be green and will report how many jobs and rules snakemake plans to run. This will allow you to evaluate any error and syntax messages.  

Once ready, use the submit-slurm.sh script to submit the jobs to slurm. Run with screen, tmux, or nohup.
```
bash submitscripts/submit-slurm.sh
# This will print jobs submitted as it runs. Monitor these jobs using ```squeue```

```

### Troubleshooting

Sharing my most common errors! yay mistakes and frustrating code!

```
# My command to run the dry run:
(snake-qc) [sarahhu@pn072 qc-trim]$ snakemake -np

# Error message
Building DAG of jobs...
MissingInputException in line 50 of /vortexfs1/omics/huber/shu/18S-mcr2021-GRcones/qc-trim/Snakefile:
Missing input files for rule fastqc:
/vortexfs1/omics/huber/data/18s-midcaymanrise-gordacones-2021-06-28/95_GR_substrate_MC6_Shell_8_5_Jun2021_L001_R2_001.fastq.gz
```

The first thing I did was migrate to that directory where snakemake was claiming I had a missing sequence. Needed to make sure (1) the script is using the intended wild cards to select the file names and (2) that my raw sequence read directory actually had all of the R1 and R2 files for each sample. In this particular instance, I found out that I was missing the R2 for this sample. 

Note that the first time you execute this Snakemake, it will need to create several new conda environments so it can flip between the ones it needs during the run. Because of this, this is what the first little while will look like when you execute a Snakemake run:
```
Building DAG of jobs...
Creating conda environment https:/bitbucket.org/snakemake/snakemake-wrappers/raw/0.35.2/bio/fastqc/environment.yaml...
Downloading remote packages.
Environment for ../../../../../../tmp/tmpay2xbott.yaml created (location: .snakemake/conda/1e45dac1)
Creating conda environment envs/multiqc-env.yaml...
Downloading remote packages.
Environment for envs/multiqc-env.yaml created (location: .snakemake/conda/6b9f0414)
Creating conda environment https:/bitbucket.org/snakemake/snakemake-wrappers/raw/0.35.2/bio/trimmomatic/pe/environment.yaml...
Downloading remote packages.

## and so forth...

```



This is the successful output from the dry run scripts:
```
Job counts:
        count   jobs
        1       all
        78      fastqc
        78      fastqc_trim
        1       multiqc
        39      trimmomatic_pe
        197
This was a dry-run (flag -n). The order of jobs does not reflect the order of execution.
```



***
_Last updated July 2021_
