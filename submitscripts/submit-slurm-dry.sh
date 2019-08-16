#!/bin/bash

snakemake -np \
        --jobs 100 --use-conda --cluster-config submitscripts/cluster.yaml --cluster "sbatch --parsable --qos=unlim --partition={cluster.queue} --job-name=QC.{rule}.{wildcards} --mem={cluster.mem}gb --time={cluster.time} --ntasks={cluster.threads} --nodes={cluster.nodes}"

