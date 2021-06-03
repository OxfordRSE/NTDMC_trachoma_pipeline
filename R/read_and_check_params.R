read_param_file <- function (param_file_path, ess_not_reached_dir) {
    params <- yaml::read_yaml(param_file_path)
    expected_types <- list(
        "data_file"="character",
        "nsamples_map"="integer",
        "nsamples"="integer",
        "delta"="integer",
        "T"="integer",
        "target_ess"="integer",
        "nsamples_resample"="integer",
        "resample_path"="character",
        "python"="character"
    )
    for (name in names(params)) {
        if (!(name %in% names(expected_types))) {
            msg <- sprintf(
                "Bad entry in parameter file: '%s' not recognised", name
            )
            stop(msg)
        }
        if (!(typeof(params[[name]]) == expected_types[[name]])) {
            msg <- sprintf(
                "Wrong type for parameter %s: got %s, expected %s",
                name,
                typeof(params[[name]]),
                expected_types[[name]]
            )
            stop(msg)
        }
    }

    ensure_output_directory_structure(params[["resample_path"]], ess_not_reached_dir)
    if (!("python" %in% names(params))) params[["python"]] <- Sys.which("python3")

    return(params)
}

ensure_output_directory_structure <- function(output_dir, ess_not_reached_dir) {
    ensure_dir <- function(dir) if (!dir.exists(dir)) dir.create(dir)
    ensure_dir(output_dir)
    ensure_dir(file.path(output_dir, ess_not_reached_dir))
    dirs <- c("model_output", "model_input", "mda_files", "prevalence_maps",
              "sampled_parameters")
    for (dir in dirs) {
        ensure_dir(file.path(output_dir, dir))
        ensure_dir(file.path(output_dir, ess_not_reached_dir, dir))
    }
}
