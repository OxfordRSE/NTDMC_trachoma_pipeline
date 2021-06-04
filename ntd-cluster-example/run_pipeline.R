library(trachomapipeline)

jobid <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

dopipeline("input.yaml", jobid)
