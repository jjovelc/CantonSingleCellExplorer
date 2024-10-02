# modules/plots_ui.R

source("global.R")
source("server.R")
source("modules/ui/home_ui.R")
source("modules/ui/plots_ui.R")
source("modules/ui/analysis_ui.R")
source("modules/ui/help_ui.R")
source("modules/helpers/plotting.R")

ui <- fluidPage(
  theme = shinytheme("cerulean"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "www/styles.css"),
    tags$style(HTML("
      /* Enable scrolling on tab content */
      .tab-pane {
        overflow-y: auto;
        max-height: calc(100vh - 120px); /* Adjust the 120px as needed */
      }
    "))
  ),
  navbarPage(
    title = "Canton Lab's Single Cell Explorer",
    tabPanel("Home", home_ui("home")),
    tabPanel("Plots", plots_ui("plots")),
    tabPanel("Analysis", analysis_ui("analysis")),
    tabPanel("Help", help_ui("help"))
  )
)