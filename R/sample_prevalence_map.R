sample_prevalence_map_at_IUs <- function(stats_for_ius, n.map.sampl, seed = NULL) {
    sample_map <- function(IU_index) {
        set.seed(seed) # For comparison with test data with `set.seed(Scen[iscen])`
        rnorm(n.map.sampl, mean = stats_for_ius[IU_index,1], sd = stats_for_ius[IU_index,2])
    }
    L <- lapply(IU_indices, sample_map)
    prev <- sapply(L, function(x) exp(x)/(1+exp(x)))

    return(
        t(prev*100)
    )
}
