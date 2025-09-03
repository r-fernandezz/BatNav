######################### Read all libraries #########################
library(desc)
pkgs <- desc::desc_get_deps(file = here::here("DESCRIPTION"))
pkgs <- pkgs$package[pkgs$type %in% c("Imports", "Depends")]

invisible(lapply(pkgs, require, character.only = TRUE))

######################### Shiny option #########################
options(shiny.maxRequestSize = 100*1024^2)

######################### Variables used into app #########################
PNR_shp <-  st_read(here::here("data", "PNR_2021_peigeo", "PNRun2021.shp"))