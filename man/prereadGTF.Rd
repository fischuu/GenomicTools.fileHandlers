% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/prereadGTF.R
\name{prereadGTF}
\alias{prereadGTF}
\title{prereadGTF}
\usage{
prereadGTF(file, nrow = 1000, skip = "auto")
}
\arguments{
\item{file}{Filename}

\item{nrow}{Number of rows to read}

\item{skip}{Rows to skip from top}
}
\value{
A list of available features
}
\description{
Preread a gtf file and prints features of it for importing it.
}
\details{
This function reads in a gtf file and prints its features for the import step. 

By default this function only imports the first 1000 rows, in case all rows should be imported set \code{nrow=-1}.

The number to skip in the beginning can be adjusted by the \code{skip} option. The default is here \code{auto} so that
the function can identify the correct amount of header rows. Hence, this option should be changed only, if there is a
good reason.
}
\author{
Daniel Fischer
}
