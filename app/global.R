###############################################################################
# Act-Like-Me
#
# Author: Garvin Kruthof
# Created 2019-01-30 19:34:54
###############################################################################


# Dependencies ------------------------------------------------------------
library(shiny)
library(tidyverse)
library(janitor)
library(highcharter)
library(lubridate)
library(leaflet)
library(shinycssloaders)
library(sp)
library(shinymaterial)
library(shinyWidgets)
library(dplyr)
library(purrr)
library(readr)
library(stringr)
library(magrittr)
library(RNetLogo)
library(ggplot2)

source("/srv/shiny-server/Covid19_test/model/sim.R")
