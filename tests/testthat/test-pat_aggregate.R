# context("test-pat_aggregate")
# 
# test_that("consistent aggregation results", {
#   data("example_pat")
# 
#   # Load aggregate results from 2019-07-03
#   #pkg_path <- file.path(system.file(package = "AirSensor"))
#   #file_path <- paste0(pkg_path, "/data/example_pat_aggr_test.rda")
#   #pat_aggr_previous <- get(load(file_path))
# 
#   pat_aggr_previous <- get(load("example_pat_aggr_test.rda"))
#   pat_aggr_current <- pat_aggregate(example_pat)
# 
#   are_same <- identical(pat_aggr_current, pat_aggr_previous)
# 
#   # NOTE: Need new example_pat_aggr_test.rds to match
#   # areSame <- identical(pat_aggr_attempt, pat_aggr_template)
#   # expect_true(areSame)
# })
