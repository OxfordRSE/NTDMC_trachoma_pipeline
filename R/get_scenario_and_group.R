get_scenarios_or_groups <-function(data) {
    scenar_and_group_data <- data.frame(data$Scenario, data$Group)
    colnames(scenar_and_group_data) <- c("scenarios", "groups")
    scenar_group_pairs = unique(scenar_and_group_data)
    if (any(scenar_group_pairs$group == 7)) {
        high_prevalence_rows <- which(scenar_group_pairs$group == 7)
        return(scenar_group_pairs[-high_prevalence_rows,])
    }
    ## If none of the pair has group 7 then return the full matrix
    ## ("which(scenar_group_pairs$group == 7)"
    ## would return "integer(0)" in this case)
    return(scenar_group_pairs)
}

get_group_id <-function(jobid, data) {
    scenarios_and_groups <- get_scenarios_or_groups(data)
    return(
        scenarios_and_groups$groups[jobid]
    )
}

get_scenario_id <-function(jobid, data) {
    scenarios_and_groups <- get_scenarios_or_groups(data)
    return(
        scenarios_and_groups$scenarios[jobid]
    )
}

    
