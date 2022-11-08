
required_packages <- c(
  "config",
  "shinycssloaders",
  "rintrojs",
  "shinyWidgets",
  "shinythemes",
  "officer",
  "tinytex",
  "gridExtra",
  "flextable",
  "shiny",
  "devtools",
  "leaflet",
  "shinyjs",
  "shinyalert",
  "reactlog"
)


# install missing packages
new.packages <- required_packages[!(required_packages %in% installed.packages()[,"Package"])]

if (length(new.packages)) {
  install.packages(new.packages)
}

library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyjs)
library(shinycssloaders)
library(shinyalert)
library(DT)
library(RColorBrewer)
library(geojsonio)
library(jsonlite)
library(ggplot2)
library(reshape2)
library(plyr)
library(tidyverse)
library(ggpol)
require(RColorBrewer)
library(httr)
library(htmltools)
library(config)
library(plotly)
library(xlsx)
library(raster)
library(tidyverse)
library(rintrojs)
library(shinyWidgets)
library(shinythemes)
library(officer)
library(tinytex)
library(gridExtra)
library(flextable)
library(leaflet)
library(reactlog)


