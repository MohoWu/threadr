% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/base_df.R
\name{base_df}
\alias{base_df}
\title{Function to catch \code{dplyr}'s \code{tbl_df} data frame class and convert 
to a standard/base data frame.}
\usage{
base_df(df)
}
\arguments{
\item{df}{A \code{tbl_df} to be converted into a standard data frame.}
}
\description{
The different type of data frame in \code{dplyr} can cause failures for some 
functions. \code{base_df} degrades a \code{tbl_df} to a base data frame.
}
\author{
Stuart K. Grange
}
