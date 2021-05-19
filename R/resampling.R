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

write_mda_file <- function(mda_years, start_year, end_year, mda_filename) {
    years <- list(
        "start_sim_year" = start_year,
        "end_sim_year" = end_year,
        "first_mda" = mda_years$first_mda,
        "last_mda" = mda_years$last_mda
        )
    write.csv(mda_years,
              mda_filename,
              row.names = F
              )
}
    
resample <- function(model_func, params_and_seeds, iucode, mda_file) {
    write.csv(
        params_and_seeds,
        file = paste("files200/InputBet_", iucode, ".csv", sep=""),
        row.names = F
    )
    prevalence_output <- paste("output200/OutputPrev_", iucode, ".csv'", sep="")
    infect_output <- paste("output200/InfectFilePath_", iucode, ".csv'", sep="")
    outputs_file <- paste("output200/OutputVals_", IUCodes[i], ".p'", sep="")
    model_func(
        inputbeta,
        inputMDA,
        prevalence_output,
        infect_output,
        SaveOutput=TRUE,
        OutSimFilePath=outputs_file,
        InSimFilePath=NULL
    )
}

                        

