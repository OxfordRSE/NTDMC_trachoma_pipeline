#!/bin/bash 
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=2
#SBATCH --time=48:00:00
#SBATCH --partition=ntd
#SBATCH -a 1-264
#SBATCH --mem-per-cpu=3882

module load gnu7/7.3.0
module load R

time R --vanilla < Trachoma_AMIS_perprev.r > Quick_basic
