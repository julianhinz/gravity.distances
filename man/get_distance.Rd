% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/functions.R
\name{get_distance}
\alias{get_distance}
\title{Distance between two geographic entities}
\usage{
get_distance(origin, destination, year = 2012, theta = -1,
  data = NULL, code_format = "iso3c", data_url = NULL,
  data_store = T)
}
\arguments{
\item{origin}{Vector containing origin entities. (character)}

\item{destination}{Vector containing destination entities. (character)}

\item{year}{Vector containing years between 1992 and 2012, defaults to 2012 (numeric)}

\item{theta}{Vector containing theta value between -1 and 1, defaults to -1 for the harmonic mean. Set to 0 for geometric mean, 1 for arithmetic mean. (numeric)}

\item{data}{Data.table with computed distances, defaults to gravity.distances::distances_data}

\item{code_format}{Character string indicating format of origin and destination corresponding to the countrycode package. Defaults to "iso3c".}

\item{data_url}{Character string indicating url from which data should be downloaded.}

\item{data_store}{Logical indicator whether downloaded data should be stored permanently.}
}
\description{
This function allows you to get distances between two geographic entities.
}
\examples{
get_distance("DEU", "CAN")
}
\keyword{distances}
