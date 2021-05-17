sample_prevalence_map_at_IUs <- function(IU_indices, n.map.sampl, scenario_id) {
    prev = matrix(NA, ncol = n.map.sampl, nrow = length(IU_indices))
    sample_map <- function(IU_index) {
        set.seed(scenario_id) # For comparison with test data with `set.seed(Scen[iscen])`
        rnorm(n.map.sampl, Data$Logit[IU_index], sd = Data$Sds[IU_index])
    }
    L <- lapply(IU_indices, sample_map)
    prev <- sapply(L, function(x) exp(x)/(1+exp(x)))

    return(
        t(prev*100)
    )
}
