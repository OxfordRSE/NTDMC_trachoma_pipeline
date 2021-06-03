extract_amis_params <- function(params) {
    names <- c("nsamples", "delta", "T", "target_ess")
    return (
        params[names]
    )
}
#' @export
dopipeline <- function(parameter_file, jobid) {
    ess_not_reached_dir <- "ess_not_reached"
    params <- read_param_file(parameter_file, ess_not_reached_dir)

    ### Read data
    data <- read.csv(params[["data_file"]])
    grouped_data <- group_ius_according_to_mean_prevalence(data)

    scenario_id <- get_scenario_id(jobid, grouped_data)
    mda_file_path <- make_mda_file(grouped_data, scenario_id, jobid)

    ## Compute prevalence map for ius in job
    stats_for_ius <- extract_IU_stats_from_data(jobid, grouped_data)
    map_file <- file.path(
        params[["resample_path"]], "prevalence_maps", sprintf("map_job%g.csv", jobid)
    )
    prevalence_map <- sample_prevalence_map_at_IUs(
        stats_for_ius, n.map.sampl = params[["nsamples_map"]], file = map_file
    )

    ## Sample models parameters using AMIS algorithm
    reticulate::use_python(params[["python"]], required = TRUE)
    trachoma_module <- reticulate::import("trachoma")
    model_func <- trachoma_module$Trachoma_Simulation
    wrapped_model <- get_model_wrapper(model_func, scenario_id, mda_file_path)
    amis_params <- extract_amis_params(params)
    ess_not_reached <- FALSE
    param_and_weights <- withCallingHandlers(
        trachomAMIS::amis(prevalence_map = prevalence_map,
                          transmission_model = wrapped_model,
                          amis_params
                          ),
        warning = function(e) ess_not_reached <<- TRUE
    )

    if(ess_not_reached) {
        params[["resample_path"]] <- file.path(params[["resample_path"]], ess_not_reached_dir)
    }

    save_parameters_and_weights(param_and_weights, params[["resample_path"]], jobid)
    ## Resample 200 trajectories from year START_YEAR
    start_year <- get_start_year(data[["start_MDA"]])
    iucodes <- rownames(stats_for_ius)
    colnames(param_and_weights) <- c("seeds", "beta", "sim_prev", iucodes)
    for (iucode in iucodes) {
        sampled_params <- sample_init_values(
            params = param_and_weights[["beta"]],
            weights = param_and_weights[[iucode]],
            seeds = param_and_weights[["seeds"]],
            nsamples = params[["nsamples_resample"]]
        )
        write_mda_file(
            get_mda_years(scenario_id, data),
            start_year,
            end_year = 2019,
            iucode,
            params[["resample_path"]]
        )
        write_parameter_file(sampled_params, iucode, params[["resample_path"]])
        resample(model_func, iucode, params[["resample_path"]])
    }
}

save_parameters_and_weights <- function(param_and_weights, resample_path, jobid) {
    filename <- sprintf("params_and_weights_%g.csv", jobid)
    full_path <- file.path(resample_path, "sampled_parameters", filename)
    write.csv(param_and_weights, file = full_path, row.names = F)
}
