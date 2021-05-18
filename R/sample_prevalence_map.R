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
