library(trachomapipeline)

IUCodes <- c("ETH18551", "ETH18604", "ETH18612")
expected_scenarios <- c(36, 28, 45)
expected_groups <- c(2, 3, 3)
data <- data.frame(IUCodes,
                   expected_scenarios,
                   expected_groups,
                   stringsAsFactors = F
                   )
colnames(data) <- c("IUcodes", "Scenario", "Group")

test_that("the right scenario is assigned to a jobid", {
    test_jobids <- 1:3
    scenarios <- sapply(test_jobids, get_scenario_id, data)
    expect_identical(scenarios, expected_scenarios)
})

test_that("the right group scenario is assigned to a jobid", {
    test_jobids <- 1:3
    groups <- sapply(test_jobids, get_group_id, data)
    expect_identical(groups, expected_groups)
})
