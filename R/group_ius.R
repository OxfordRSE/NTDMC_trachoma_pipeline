get_group_id_from_iuprev <- function(prevalence_value) {
        if (prevalence_value>=0 & prevalence_value<10)
        {
            return(1)
        } else if (prevalence_value>=10 & prevalence_value<20) {
            return(2)
        } else if (prevalence_value>=20 & prevalence_value<30) {
            return(3)
        } else if (prevalence_value>=30 & prevalence_value<40) {
            return(4)
        } else if (prevalence_value>=40 & prevalence_value<50) {
            return(5)
        } else if (prevalence_value>=50 & prevalence_value<60) {
            return(6)
        } else {
            return(7)
        }
}

estimate_mean_prevalence <- function(stats, nsamples) {
    logit <- stats[1]
    std <- stats[2]
    L <- rnorm(nsamples, logit, std)
    return(
        mean(100 * (exp(L)/(1+exp(L))))
    )
}

#' Group Implementation Units (IUs) according to value of mean
#' prevalence estimated from data
#'
#' This functions reads in statistical prevalence data, in the form of
#' a logit and standard deviation value, for a range of IUs. For each
#' IU, it estimates the mean infection prevalence and determines in
#' which group the IU falls into.
#'
#' @param data A dataframe containing a column named "Logit" and
#'     another called "Sds" containing the statistical data. The
#'     dataframe must have one row per IU
#' @param nsamples An integer describing the number of samples to use
#'     when evaluating the mean prevalence from the logit and std
#'     values.
#' @return The same dataframe as \code{data} with an added column
#'     containing the group number for each row (IU)
#' @export
group_ius_according_to_mean_prevalence <- function(data, nsamples) {
    logit_and_std_matrix <- cbind(data$Logit, data$Sds)
    prev_for_ius <- apply(
        logit_and_std_matrix, 1, estimate_mean_prevalence, nsamples
    )
    group_for_ius <- sapply(
        prev_for_ius, get_group_id_from_iuprev
    )   
    return(
              cbind(data, group_for_ius)
        )
}
