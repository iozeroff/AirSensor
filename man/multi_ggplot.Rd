% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils-plot.R
\name{multi_ggplot}
\alias{multi_ggplot}
\title{Display multiple plots on one page}
\usage{
multi_ggplot(..., plotList = NULL, cols = 1, layout = NULL)
}
\arguments{
\item{...}{any number of ggobjects to be plotted}

\item{plotList}{a list() of any number of ggplot objects to plot on a single pane}

\item{cols}{Number of columns in the plot layout}

\item{layout}{A matrix specifying the layout. If present, 'cols' is ignored.}
}
\description{
# A plotting function that uses ggplot2 to display multiple 
ggplot objects in a single pane.
}
\note{
Additional documentation of the multiplot algorithm is available at 
cookbook-r.com.
}
