## MSc Introduction to Health Analytics Group Project Code

## Install necessary packages
## This is a list of the packages you might need. Just add to the list if you want to install more.
packages = (c("ipumsr", "dplyr", "ggplot2", "tidyr", "here", "rmdformats", "srvyr"))

## Now load or install&load all
package.check <- lapply(
  packages,
  FUN = function(x) {
    if (!require(x, character.only = TRUE)) {
      install.packages(x, dependencies = TRUE)
      library(x, character.only = TRUE)
    }
  }
)

## Set the working directory
setwd(here())

## Read in data
data <- read_ipums_ddi("filename")