#' @export
dopipeline <- function(parameter_file, jobid) {
    params <- read_param_file(parameter_file)

    ### Read data
    data <- read.csv(params[["data_file"]])
    grouped_data <- group_ius_according_to_mean_prevalence(data)

    ## Get ius for this specific job
    scenario_id <- get_scenario_id(jobid, grouped_data)
    group_id <- get_group_id(jobid, grouped_data)
    IU_scen <- which(
        grouped_data$Scenario == scenario_id & grouped_data$Group == group_id
    )

    mda_limit_years <- get_mda_years(scenario_id, grouped_data)
    start_year <- mda_limit_years["first_mda"] - 1
    end_year <- 2019
    mda_file_path <- write_mda_file(
        mda_limit_years, start_year, end_year, sprintf("jobid%g", jobid), "."
    )
    ## Compute prevalence map for ius in job
    stats_for_ius <- cbind(grouped_data$Logit[IU_scen], grouped_data$Sds[IU_scen])
    prevalence_map <- sample_prevalence_map_at_IUs(
        stats_for_ius, n.map.sampl = params[["nsamples_map"]], seed = jobid
    )

    ## Sample models parameters using AMIS algorithm
    reticulate::use_python(params[["python"]], required = TRUE)
    transmission_model <- reticulate::import("trachoma")
    model_func <- transmission_model$Trachoma_Simulation
    IO_file_id <- sprintf("scen%g_group%g", scenario_id, group_id)
    param_and_weights <- trachomAMIS::amis(prevalence_map = prevalence_map,
                                           transmission_model = model_func,
                                           n_params = 2,
                                           nsamples = params[["nsamples"]],
                                           IO_file_id,
                                           delta = params[["delta"]],
                                           T = params[["T"]],
                                           target_ess = params[["target_ess"]],
                                           mda_file = mda_file_path
                                           )
    ## Resample 200 trajectories from year START_YEAR
    start_year <- get_start_year(data[["start_MDA"]])
    colnames(param_and_weights) <- c(
        "seeds", "beta", "sim_prev",
        grouped_data$IUCodes[IU_scen]
    )
    for (iucode in grouped_data$IUCodes[IU_scen]) {
        sampled_params <- sample_init_values(
            params = param_and_weights[["beta"]],
            weights = param_and_weights[[iucode]],
            seeds = param_and_weights[["seeds"]],
            nsamples = params[["nsamples_resample"]]
        )
        write_mda_file(
            mda_limit_years,
            start_year,
            end_year = 2019,
            iucode,
            params[["resample_path"]]
        )
        write_parameter_file(sampled_params, iucode, params[["resample_path"]])
        resample(model_func, iucode, params[["resample_path"]])
    }
}
