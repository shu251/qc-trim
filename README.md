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
```
# Change to location of all raw .fastq (or .fastq.gz) files
raw_data: /vortexfs1/omics/huber/shu/qc-trim/raw_data

# Change to output directory (on HPC, use your scratch)
scratch:  /vortexfs1/scratch/sarahhu

# Add a project name, output files will be placed in a directory of this name in scratch
proj_name: test-qc

# Change to output directory to eventually move all trimmed reads to
outputDIR: /vortexfs1/omics/huber/shu/qc-trim
```

### _(3) Change parameters of Trimmomatic step_

Update location of adapters for trimmomatic to use. Trimmomatic parameters are written into Snakefile, see line *67*.
```
adapters: [PATH TO ADAPTERS.fa]
```

### _(4) Execute dryrun of snakemake pipeline_

```
snakemake -np
```

### _(5) Execute snakemake_

```
snakemake --use-conda
```

_to do_
* Update to export a list of file names - could be used for next pipeline?
* Update to give warning if R1 and R2s do not match, or if one is missing!
* Update to move output trimmed and QC stats to an output directory
