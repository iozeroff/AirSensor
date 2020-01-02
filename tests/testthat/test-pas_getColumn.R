context("test-pas_getColumn")

# Data used in all examples
data("example_pas")

test_that("input validation works", {
  expect_error(pas_getColumn(NULL))
  expect_error(pas_getColumn(1:10))
})

test_that("filtering works", { 
  # Many DEVICE_LOCATIONTYPE values are NA and don't show up as TRUE or FALSE
  expect_equal(length(pas_getColumn(example_pas, "ID", isOutside = TRUE)), 4100)
  expect_equal(length(pas_getColumn(example_pas, "ID", isOutside = FALSE)), 891)
  # State counts when example_pas was created
  expect_equal(length(pas_getColumn(example_pas, "ID", states = c("WA", "OR"))), 378)
  expect_equal(length(pas_getColumn(example_pas, "ID", states = c("CA"))), 1995)
})

test_that("proper column is extracted", { 
  # ID
  expect_equal(
    pas_getColumn(example_pas, "ID", states = "SD"),
    c("3097", "26059", "2506" , "8376", "5656")
  )
  # Label
  expect_equal(
    pas_getColumn(example_pas, "label", states = "SD"),
    c(
      "Cat Ranch",
      "Garfield School",
      "Golden Valley",
      "MandMnorth40",
      "West Rapid City"
    )
  )
  # pm25
  expect_equal(
    pas_getColumn(example_pas, "pm25", states = "SD"),
    c(7.09, 8.04, 0.00, 18.00, 0.00)
  )
})

test_that("pas_getIDs() and pas_getLabels() work", { 
  # pas_getIDs()
  expect_equal(
    pas_getIDs(example_pas, states = "SD"),
    c("3097", "26059", "2506" , "8376", "5656")
  )
  # pas_getLabels()
  expect_equal(
    pas_getLabels(example_pas, states = "SD"),
    c(
      "Cat Ranch",
      "Garfield School",
      "Golden Valley",
      "MandMnorth40",
      "West Rapid City"
    )
  )
})
