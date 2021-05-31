library(trachomapipeline)

test_that("ius are assigned the correct group", {
    logits <- c(
        -2.296124601,
        -1.814302776,
        -1.28066311,
        -0.773342758,
        -0.274816878,
        0.119977418,
        0.803090312
    )
    sds <- c(
        0.280844415,
        0.243590266,
        0.255922043,
        0.237900171,
        0.276948445,
        0.245386215,
        0.390467676
    )

    iucodes <- c(
        "ETH19289",
        "ETH18551",
        "ETH18604",
        "ETH18656",
        "ETH19167",
        "ETH19231",
        "CAF09651"
    )
    data <- data.frame(logits, sds, iucodes, stringsAsFactors = F)
    colnames(data) <- c("Logit", "Sds", "IUCodes")
    grouped_data <- group_ius_according_to_mean_prevalence(data, nsamples = 3000)
    expected_dataframe <- cbind(data, Group=c(1,2,3,4,5,6,7))
    expect_identical(grouped_data, expected_dataframe)
 })

test_that("the correct stats are extracted for ius", {
    Scenario <- c(36, 46, 36, 28, 36)
    Group <- c(2, 3, 2, 3, 2)
    IUCodes <- c("ETH18551", "ETH18568", "ETH18559", "ETH18644", "ETH18541")
    Logit <- rnorm(5)
    Sds <- rnorm(5)

    expected_stats <- cbind(Logit[c(1,3,5)], Sds[c(1,3,5)])
    rownames(expected_stats) <- IUCodes[c(1,3,5)]
    data <- data.frame(IUCodes, Logit, Sds, Scenario, Group)

    stats <- extract_IU_stats_from_data(jobid = 1, data = data)

    expect_identical(stats, expected_stats)
})
