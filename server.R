# server.R

library(shiny)
library(shinydashboard)

# Source global and module scripts
source("global.R")
source("modules/server/home_server.R")
source("modules/server/plots_server.R")
source("modules/server/analysis_server.R")
source("modules/server/help_server.R")

options(shiny.maxRequestSize = 500*1024^2)
#options(shiny.autoreload = FALSE)

server <- function(input, output, session) {
  
  # Call the Home module and get the selected RDS file
  selected_file <- callModule(home_server, "home")
  
  # Reactive expression to load the selected Seurat object
  seurat_object <- reactive({
    req(selected_file())
    
    
    
    withProgress(message = "Loading Seurat objects...", value = 0, {
      incProgress(0.5)
      data <- tryCatch({
        loadSeuratObject(selected_file())
      }, error = function(e) {
        flog.error("Error loading Seurat object: %s", e$message)
        NULL
      })
      incProgress(1)
    })
    
    removeModal()
    
    if (!is.null(data) && inherits(data, "Seurat")) {
      flog.info("Seurat object loaded successfully")
    } else {
      flog.warn("Seurat object not loaded or is not a valid Seurat object")
    }
    
    data
  })
  
  # Observe the availability of the Seurat object
  observe({
    if (!is.null(seurat_object())) {
      flog.info("Seurat object is available")
    } else {
      flog.warn("Seurat object is not available")
    }
  })
  
  # Call the Plots and Analysis modules, passing the reactive Seurat object
  callModule(plots_server, "plots", seurat_object)  # Use seurat_object here
  callModule(analysis_server, "analysis", seurat_object)  # Use seurat_object here
  callModule(analysis_server, "analysis1", obj = seurat_obj)
  
}