# modules/server/home_server.R

home_server <- function(input, output, session) {
  
  # Directory containing the Seurat RDS files
  seurat_dir <- '/Users/juanjovel/OneDrive/jj/UofC/data_analysis/jonathanCanton/'
  
  # List all RDS files in the directory
  rds_files <- list.files(path = seurat_dir, pattern = "\\.rds$", full.names = FALSE)
  
  # Update the selectInput with the RDS file names
  updateSelectInput(session, "seurat_file",
                    choices = rds_files,
                    selected = rds_files[1])
  
  # Return the selected file as a reactive expression
  reactive({
    req(input$seurat_file)
    input$seurat_file
  })
}