# server.R

# Source global and module scripts
source("global.R")
source("modules/server/home_server.R")
source("modules/server/plots_server.R")
source("modules/server/analysis_server.R")
source("modules/server/help_server.R")

options(shiny.maxRequestSize = 500*1024^2)

server <- function(input, output, session) {
  
  # Call the Home module and get the selected RDS file when load_file button is clicked
  selected_file <- callModule(home_server, "home")
  
  # Define the directory where the RDS files are located
  seurat_dir <- 'data'  # Adjust the path if necessary
  
  # Reactive expression to load the Seurat object based on the selected file
  obj <- reactive({
    req(selected_file())  # Ensure a file has been selected
    filename <- selected_file()
    withProgress(message = "Loading Seurat object...", value = 0, {
      incProgress(0.5, detail = paste("Loading", filename))
      seurat_obj <- loadSeuratObject(seurat_dir, filename)
      incProgress(0.5, detail = "Seurat object loaded.")
    })
    seurat_obj
  })
  
  # Call the Plots and Analysis modules, passing the reactive Seurat object
  callModule(plots_server, "plots", obj = obj)
  callModule(analysis_server, "analysis", obj = obj)
}