#' Sample geostatistical map at given pixels
#'
#' Draw samples for each pixel of a geostatistical map. Samples are normally
#' distributed
#'
#' @param stats_for_ius A two columns matrix containing the mean and
#'     standard deviation for each pixel. (double)
#' @param n.map.sampl The number of samples to draw for each
#'     pixel. (integer)
#' @param seed The value of the ramdom seed before sampling the map
#'     (integer, optional)
sample_prevalence_map_at_IUs <- function(stats_for_ius, n.map.sampl, seed = NULL) {
    sample_map <- function(IU_index) {
        set.seed(seed) # For testing
        rnorm(n.map.sampl, mean = stats_for_ius[IU_index,1], sd = stats_for_ius[IU_index,2])
    }
    L <- lapply(1:dim(stats_for_ius)[1], sample_map)
    prev <- sapply(L, function(x) exp(x)/(1+exp(x)))

    return(
        t(prev*100)
    )
}
