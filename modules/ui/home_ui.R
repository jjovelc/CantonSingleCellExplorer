# In modules/home_ui.R

home_ui <- function(id) {
  ns <- NS(id)  # Create the namespacing function for the UI
  tagList(
    includeMarkdown("home.md"),  # Include a Markdown file
    
    # Add a selectInput for Seurat RDS file selection
    selectInput(
      ns("seurat_file"),
      "Select Seurat RDS File:",
      choices = NULL,  # To be populated dynamically
      selected = NULL
    )
  )
}





