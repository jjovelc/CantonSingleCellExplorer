# modules/server/home_server.R

home_server <- function(input, output, session) {
  ns <- session$ns  # Namespacing function
  
  # Return the selected file as a reactive expression when the button is clicked
  selected_file <- eventReactive(input$load_file, {
    req(input$seurat_file)
    input$seurat_file
  })
  
  return(selected_file)
}