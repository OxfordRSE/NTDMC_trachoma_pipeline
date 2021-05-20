read_param_file <- function (param_file_path) {
    return(
        yaml::read_yaml(param_file_path)
    )
}
