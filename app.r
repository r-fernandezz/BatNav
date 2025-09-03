# To load global script
source(here::here("R", "global.r"))

# To load all functions (except "ui", "server" and "global") used to build Shiny application
ls <- list.files(here::here("R"), full.names = TRUE)
ls_sub <- grepv("server.r|user_interface.r|global.r", ls, invert = TRUE)
lapply(ls_sub, source)

# To load server and ui functions
source(here::here("R", "user_interface.r"))
source(here::here("R", "server.r"))

# Run application
shiny::shinyApp(ui = ui, server = server, options = list(launch.browser = TRUE))
