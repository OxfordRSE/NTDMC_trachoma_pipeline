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

extract_IU_stats_from_data <- function(jobid, data) {
    if (!("Group" %in% colnames(data))) {
        stop("dataframe has no column named 'Group'")
    }
    scenario_id <- get_scenario_id(jobid, data)
    group_id <- get_group_id(jobid, data)
    iu_indices <- which(
        data$Scenario == scenario_id & data$Group == group_id
    )
    stats_for_ius <- cbind(data$Logit[iu_indices], data$Sds[iu_indices])
    rownames(stats_for_ius) <- data$IUCodes[iu_indices]
    return(stats_for_ius)
}

get_mda_years <- function(scenario_id, data) {
    idx <- match(scenario_id, data$Scenario)
    first_mda <- data$start_MDA[idx]
    last_mda <- data$last_MDA[idx]
    return(
        c("first_mda" = first_mda, "last_mda" = last_mda)
    )
}

