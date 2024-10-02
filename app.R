# app.R
source("global.R")
source("ui.R")
source("server.R")
source("modules/ui/home_ui.R")
source("modules/ui/help_ui.R")
source("modules/ui/plots_ui.R")
source("modules/ui/analysis_ui.R")

ui <- fluidPage(
  theme = shinytheme("cerulean"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
  ),
  div(class = "navbar-fixed-top",
      navbarPage(
        title = "Canton Lab's Single Cell Explorer",
        tabPanel("Home", home_ui("home")),      # Home tab with RDS selection
        tabPanel("Plots", plots_ui("plots")),   # Plots tab
        tabPanel("Analysis", analysis_ui("analysis")),  # Analysis tab
        tabPanel("Help", help_ui("help"))
      )
  )
)

#shinyApp(ui, server)
shinyApp(ui, server, options = list(width = 2400, height = 1200))
