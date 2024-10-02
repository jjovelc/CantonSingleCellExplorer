# modules/home_ui.R

home_ui <- function(id) {
  ns <- NS(id)  # Create the namespacing function for the UI
  
  # Directory containing the Seurat RDS files
  seurat_dir <- 'data'
  
  # List all RDS files in the directory
  rds_files <- list.files(path = seurat_dir, pattern = "\\.rds$", full.names = FALSE)
  
  tagList(
    # Corrected tags$link() to properly link the stylesheet
    tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
      ),
    
    includeMarkdown("home.md"),  # Include a Markdown file
    
    # Add a selectInput for Seurat RDS file selection
    selectInput(
      ns("seurat_file"),
      "Select Seurat RDS File:",
      choices = rds_files,  # Use the list of files directly
      selected = rds_files[1]
    ),
    
    # Add a button to load the selected file
    
    actionButton(ns("load_file"), "Load RDS File", style = "border: 2px solid ; background-color: dodgerblue; color: black")
  )
}