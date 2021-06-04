# Installation

1. Load required modules

```shell
module load gnu7 R python
```

2. Install pipeline package and AMIS package

```R
devtools::install_github("OxfordRSE/trachomAMIS")
devtools::install_github("OxfordRSE/NTDMC_trachoma_pipeline")
```
3. Clone trachoma and install Python model

```shell
git clone https://github.com/ArtRabbitStudio/ntd-model-trachoma.git
python3 -m pip install ntd-model-trachoma/
```

# Running the pipeline

1. Make sure you're happy with the parameters in `input.yaml`
2. Submit jobs with

```shell
sbatch batch.sh
```

# Overview

Submission script submits a range of jobs to SLURM. Each job run the R
script `run_pipeline.R`.  Script `run_pipeline.R` loads the pipeline
package and executes the trachoma pipeline for this particular job.
