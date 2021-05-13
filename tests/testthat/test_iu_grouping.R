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
    expected_dataframe <- cbind(data, group_for_ius=c(1,2,3,4,5,6,7))
    expect_identical(grouped_data, expected_dataframe)
 })
