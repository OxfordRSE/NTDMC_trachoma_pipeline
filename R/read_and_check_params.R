read_param_file <- function (param_file_path) {
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

    if (!dir.exists(params[["resample_path"]])) dir.create(params[["resample_path"]])

    return(params)
}

