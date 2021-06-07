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

write_mda_file <- function(mda_years, start_year, end_year, mda_file_path) {
    years <- list(
        "start_sim_year" = start_year,
        "end_sim_year" = end_year,
        "first_mda" = mda_years["first_mda"],
        "last_mda" = mda_years["last_mda"]
    )
    write.csv(years, mda_file_path, row.names = F)
}

make_mda_file <- function(data, scenario_id, dir, suffix) {
    mda_limit_years <- get_mda_years(scenario_id, data)
    start_year <- get_start_year(data[["start_MDA"]])
    end_year <- 2019
    if (!(dir.exists(dir))) dir.create(dir)
    mda_file_path <- file.path(dir, sprintf("InputMDA_%s.csv", suffix))
    write_mda_file(mda_limit_years, start_year, end_year, mda_file_path)
    return(mda_file_path)
}
