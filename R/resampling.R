#' Sample parameter values
#' 
#' Given an ensemble of parameters and their associated weight,
#' this function returns a vector of NSAMPLES parameters.
#'
#' @param param_and_weights A two column matrix of parameters (first
#'     column) and weights (second column)
#' @param nsamples The number of parameters to draw
#' @return A 2 columns matrix containing the sampled parameters and
#'     associated seed. First column is seeds
sample_init_values <- function(params, weights, seeds, nsamples) {
    sampled_idx <- sample.int(
        length(params),
        nsamples,
        replace = F,
        prob = weights
    )
    sampled <- cbind(seeds[sampled_idx], params[sampled_idx])
    colnames(sampled) = c("randomgen", "bet")
    return(sampled)
}

write_parameter_file <- function(params_and_seeds, iucode, resample_path) {
    make_file_path <- function(prefix, dir) {
        file.path(resample_path, dir, sprintf("%s_%g.csv", prefix, iucode))
    }
    write.csv(
        params_and_seeds,
        make_file_path("InputBet", "model_input"),
        row.names = F
    )
}

resample <- function(model_func, iucode, resample_path) {
    make_file_path <- function(prefix, dir) {
        file.path(resample_path, dir, sprintf("%s_%g.csv", prefix, iucode))
    }
    model_func(
        make_file_path("InputBet", "model_input"),
        make_file_path("InputMDA", "mda_files"),
        make_file_path("OutputPrev", "model_output"),
        make_file_path("InfectFilePath", "model_output"),
        SaveOutput=TRUE,
        OutSimFilePath = make_file_path("OutputVals", "model_output"),
        InSimFilePath=NULL
    )
}

                        

