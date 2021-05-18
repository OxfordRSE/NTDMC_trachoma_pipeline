library(trachomapipeline)

values <- c(
    14.95203,
    13.89349,
    11.81734,
    16.69648,
    16.03149,
    13.30116,
    16.21331,
    15.43331,
    12.88844,
    19.77817,
    19.94016,
    15.96395,
    10.50745,
    8.766793,
    8.118058
)
expected_prev = matrix(values, ncol = 5, nrow = 3)

sds <- c(0.243590266, 0.312726917, 0.251354687)
logits <- c(-1.814302776, -1.921651678, -2.088197937)
stats_for_ius <- cbind(logits, sds)
rownames(stats_for_ius) <- c("ETH18551", "ETH18644", "ETH18541")

test_that("the right prevalence map is returned", {
    prev <- sample_prevalence_map_at_IUs(
        stats_for_ius,
        n.map.sampl = 5,
        seed = 36
    )
    expect_equal(prev, expected_prev, tolerance = 1e-6)
})


