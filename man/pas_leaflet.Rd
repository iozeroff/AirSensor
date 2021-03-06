% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pas_leaflet.R
\name{pas_leaflet}
\alias{pas_leaflet}
\title{Leaflet interactive map of PurpleAir sensors}
\usage{
pas_leaflet(
  pas = NULL,
  parameter = "pm25_1hr",
  paletteName = NULL,
  radius = 10,
  opacity = 0.8,
  maptype = "terrain",
  outsideOnly = TRUE
)
}
\arguments{
\item{pas}{PurpleAir Synoptic \emph{pas} object.}

\item{parameter}{Value to plot, e.g. \code{pm25_1hr}.}

\item{paletteName}{Predefined color palette name. Can be of the following:
\itemize{
\item{"AQI"}
\item{"humidity}
\item{"temperature}
\item{"distance"}
}}

\item{radius}{Radius (pixels) of monitor circles.}

\item{opacity}{Opacity of monitor circles.}

\item{maptype}{Optional name of leaflet ProviderTiles to use, e.g. \code{terrain}.}

\item{outsideOnly}{Logical specifying subsetting for monitors marked as 'outside'.}
}
\value{
A leaflet "plot" object which, if not assigned, is rendered in 
Rstudio's 'Viewer' tab.
}
\description{
This function creates interactive maps that will be displayed in 
  RStudio's 'Viewer' tab.

Typical usage would be to use the \code{parameter} argument to display pm25 
values from one of:
\itemize{
\item{"pm25_current"}
\item{"pm25_10min"}
\item{"pm25_30min"}
\item{"pm25_1hr"}
\item{"pm25_6hr"}
\item{"pm25_1day"}
\item{"pm25_1week"}
}

Auxiliary \code{parameter} arguments can be used to display various Purple Air 
sensor data. Currently supported \code{parameter} arguments include:
\itemize{
\item{"humidity"}
\item{"pressure"}
\item{"temperature"}
\item{"pwfsl_closestDistance"}
}
}
\details{
The \code{maptype} argument is mapped onto leaflet "ProviderTile" 
  names. Current mappings include:
\enumerate{
\item{"roadmap"}{ -- "OpenStreetMap"}
\item{"satellite"}{ -- "Esri.WorldImagery"}
\item{"terrain"}{ -- "Esri.WorldTopoMap"}
\item{"toner"}{ -- "Stamen.Toner"}
}

If a character string not listed above is provided, it will be used as the 
underlying map tile if available. See 
\url{https://leaflet-extras.github.io/leaflet-providers/} for a list of 
"provider tiles" to use as the background map.
}
\note{
The \code{paletteName} parameter can take the name of an RColorBrewer
paeltte, \emph{e.g.} \code{"BuPu"} or \code{"Greens"}.
}
\examples{
\dontrun{
# California
ca <-
  pas_load() \%>\%
  pas_filter(stateCode == 'CA')

pas_leaflet(ca, parameter = "pm25_1hr")

pas_leaflet(ca, parameter = "temperature")

pas_leaflet(ca, parameter = "humidity")

pas_leaflet(ca, parameter = "pwfsl_closestDistance", maptype = "satellite")
}
}
