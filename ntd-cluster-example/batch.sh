#!/bin/bash
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --time=48:00:00
#SBATCH --partition=ntd
#SBATCH -a 1-1
#SBATCH --mem-per-cpu=3882

module load gnu7/7.3.0
module load R

R --vanilla --no-save < run_pipeline.R > Quick_basic
