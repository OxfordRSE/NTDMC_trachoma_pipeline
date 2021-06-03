get_start_year <- function(mda_start_years) {
    ius_without_mdas <- which(mda_start_years == 0)
    return(
        min(mda_start_years[-ius_without_mdas]) - 1
    )
}

get_mda_years <- function(scenario_id, data) {
    idx <- match(scenario_id, data$Scenario)
    first_mda <- data$start_MDA[idx]
    last_mda <- data$last_MDA[idx]
    return(
        c("first_mda" = first_mda, "last_mda" = last_mda)
    )
}

write_mda_file <- function(mda_years, start_year, end_year,
                           iucode, resample_path) {
    years <- list(
        "start_sim_year" = start_year,
        "end_sim_year" = end_year,
        "first_mda" = mda_years["first_mda"],
        "last_mda" = mda_years["last_mda"]
    )
    mda_file_path <- file.path(resample_path, sprintf("InputMDA_%s.csv", iucode))
    write.csv(years,
              mda_file_path,
              row.names = F
              )
    return(mda_file_path)
}

make_mda_file <- function(data, jobid) {
    scenario_id <- get_scenario_id(jobid, data)
    mda_limit_years <- get_mda_years(scenario_id, data)
    start_year <- mda_limit_years["first_mda"] - 1
    end_year <- 2019
    dir <- "mda_files"; file_suffix <- sprintf("jobid%g", jobid)
    if (!(dir.exists(dir))) dir.create(dir)
    mda_file_path <- write_mda_file(
        mda_limit_years, start_year, end_year, file_suffix, dir
    )
}
