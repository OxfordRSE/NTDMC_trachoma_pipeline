#' Write input file required by transmission model
#'
#' Write a 2 columns csv file named INPUT_FILE to disk. The first column SEEDS
#' contains the seed for each parameter value. Second column BETA contains
#' corresponding parameter values.
#'
#' @param seeds A vector containing seed value for each parameter sample
#'     (double)
#' @param beta A vector containing samples of the beta parameter (double)
#' @param input_file The name of the input file (string)
write_model_input <- function(seeds, beta, input_file) {
  input_params <- cbind(seeds, beta)
  colnames(input_params) <- c("randomgen", "bet")
  write.csv(input_params, file = input_file, row.names = FALSE)
}

#' @export
get_model_wrapper <- function(model_func, scenario_id, mda_file){

  tmp_dir <- "model_io"
  make_file_path <- function(prefix) {
    file.path(tmp_dir, sprintf("%s_scen%g.csv", prefix, scenario_id))
  }
  input_file <- make_file_path("InputBet")
  output_file <- make_file_path("OutputPrev")
  infect_output <- make_file_path("InfectOutput")

  wrapper <- function(seeds, parameters) {
    dir.create(tmp_dir)
    on.exit(unlink(tmp_dir, recursive = TRUE))
    write_model_input(seeds, parameters, input_file)
    model_func(input_file, mda_file, output_file, infect_output,
               SaveOutput = F, OutSimFilePath = NULL,
               InSimFilePath = NULL)
    res <- read.csv(output_file)
    return(100 * res[, dim(res)[2]])
  }

  return(wrapper)
}
