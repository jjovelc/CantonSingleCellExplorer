# modules/ui/help_ui.R

help_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Add a custom CSS class for styling if needed
    tags$div(class = "help-content",
             # Include the Markdown file
             includeMarkdown("help.md")
    )
  )
}
