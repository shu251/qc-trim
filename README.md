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

***
_Last updated 8-18-2019_
