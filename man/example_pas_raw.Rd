% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{example_pas_raw}
\alias{example_pas_raw}
\title{Example raw Purple Air Synoptic dataset}
\format{
A tibble with 961 rows and 33 columns of data.
}
\source{
https://www.purpleair.com/json
}
\usage{
example_pas_raw
}
\description{
The \code{example_pas_raw} dataset provides a quickly loadable
version of raw Purple Air synoptic data JSON for practicing and code
examples. This dataset contains data for sensors in Washington and Oregon
and was generated on 2020-01-03 by running:

\preformatted{
  example_pas_raw <- 
    pas_downloadParseData() %>%
    dplyr::filter(Lon > -125.0 & Lon < -117.0 & Lat > 42.0 & Lat < 49.0)
  save(example_pas_raw, file = "data/example_pas_raw.rda")
}

This dataset can be converted into a standard \emph{pas} dataset with:

\preformatted{
  pas <- pas_enhanceData(example_pas_raw)
}
}
\seealso{
example_pas
}
\keyword{datasets}
