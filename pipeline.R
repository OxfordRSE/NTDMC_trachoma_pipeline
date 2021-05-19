library(trachomapipeline)

jobid <- 1

### Read data
data <- read.csv("./data/FinalData.csv")
grouped_data <- group_ius_according_to_mean_prevalence(data)

scenario_id <- get_scenario_id(jobid, grouped_data)
group_id <- get_group_id(jobid, grouped_data)
IU_scen <- which(
    grouped_data$Scenario == scenario_id & grouped_data$Group == group_id
)

stats_for_ius <- cbind(grouped_data$Logit[IU_scen], grouped_data$Sds[IU_scen])
prevalence_map <- sample_prevalence_map_at_IUs(
    stats_for_ius, n.map.sampl = 3000, seed = jobid
)

reticulate::use_virtualenv("./.venv", required = TRUE)
transmission_model <- reticulate::import("trachoma")
model_func <- transmission_model$Trachoma_Simulation
param_and_weights <- trachomAMIS::amis(prevalence_map = prevalence_map,
                                       transmission_model = model_func,
                                       n_params = 2, nsamples = 100,
                                       IO_file_id = sprintf("scen%g_group%g",
                                                            scenario_id,
                                                            group_id),
                                       delta = 5,
                                       T = T,
                                       target_ess = 250
                                       )
## Resample N trajectories
start_year <- min(data$start_MDA) - 1
mda_file <- read.csv(
    sprintf("files/InputMDA_scen%g_group%g.csv", scenario_id, group_id)
)
mda_limit_years <- mda_file[,c("first_mda", "last_mda")]
colnames(param_and_weights) <- c(
    "seeds", "beta", "sim_prev",
    grouped_data$IUCodes[IU_scen]
)
for (iucode in grouped_data$IUCodes[IU_scen]) {
    sampled_params <- sample_init_values(
        params = param_and_weights[["beta"]],
        weights = param_and_weights[[iucode]],
        seeds = param_and_weights[["seeds"]],
        nsamples = 200
    )
    mda_filename <- sprintf("files/InputMDA_%s.csv", iucode)
    write_mda_file(
        mda_limit_years,
        start_year,
        end_year = 2019,
        filename = mda_filename
    )
    resample(model_func, sampled_params, iucode, mda_filename)
}
