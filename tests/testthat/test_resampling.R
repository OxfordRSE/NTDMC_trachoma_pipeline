library(trachomapipeline)

test_that("mda file has right content", {
    expected_mda_years <- data.frame(2007, 2019, 2008, 2017)
    colnames(expected_mda_years) <- c("start_sim_year",
                                      "end_sim_year",
                                      "first_mda",
                                      "last_mda"
                                      )
    filename <- sprintf("InputMDA_ETH18544.csv")
    withr::local_file(filename)
    mda_limit_years <- data.frame(2008, 2017)
    colnames(mda_limit_years) <- c("first_mda", "last_mda")
    
    write_mda_file(
        mda_limit_years, start_year = 2002, end_year = 2019, mda_filename = filename
        )
    mda_years <- read.csv(filename)
})
