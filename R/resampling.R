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
    write.csv(
        params_and_seeds,
        file = sprintf("%s/InputBet_%g.csv", resample_path, iucode),
        row.names = F
    )
}

resample <- function(model_func, iucode, resample_path) {
    prevalence_output <- sprintf("%s/OutputPrev_%g.csv", resample_path, iucode)
    infect_output <- sprintf("%s/InfectFilePath_%g.csv", resample_path, iucode)
    outputs_file <- sprintf("%s/OutputVals_%g.p", resample_path, iucode)
    model_func(
        sprintf("%s/InputBet_%g.csv", resample_path, iucode),
        sprintf("%s/InputMDA_%s.csv", resample_path, iucode),
        prevalence_output,
        infect_output,
        SaveOutput=TRUE,
        OutSimFilePath=outputs_file,
        InSimFilePath=NULL
    )
}

                        

