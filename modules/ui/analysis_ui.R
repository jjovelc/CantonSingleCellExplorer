# modules/analysis_ui.R

analysis_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    h2("Analysis Section"),
    
    # Analysis Type Selection
    selectInput(
      ns("analysisType"),
      "Select Analysis:",
      choices = c("Summary", "Find Markers", "Differential Expression")
    ),
    
    # Conditional Panel for "Find Markers"
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Find Markers'", ns("analysisType")),
      numericInput(ns("n_markers"), "# of markers:", value = 10, min = 1, step = 1),
      helpText("Please enter an integer value.")
    ),
    
    
    
    # Conditional Panel for "Differential Expression"
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Differential Expression'", ns("analysisType")),
      selectInput(
        ns("deTest"),
        "Select DE Test Method:",
    
        choices = c("Wilcoxon", "T-test", "Bimod", "Poisson", "ROC", "NegBinom",
                    "LR", "MAST"),
        selected = "Wilcoxon"
      ),
      
      # Parameterizing Volcano Plot Thresholds
      numericInput(ns("logFC_threshold"), "Log2 Fold Change Threshold:", value = 0.25, min = 0, step = 0.05),
      numericInput(ns("pval_threshold"), "Adjusted P-value Threshold:", value = 0.05, min = 0, step = 0.01)
    ),
    
    # Execute Analysis Button
    actionButton(ns("executeAnalysis"), "Execute Analysis"),
    
    br(),
    br(),
  
    # Place the scroll message here
    uiOutput(ns("scrollMessage")),
    
      
    # Dynamic UI for Download Button
    uiOutput(ns("downloadButtonUI")),
    
    br(),
    br(),
    
    
    # Output for DataTable
    DTOutput(ns("analysisOutput")),
    
    br(),
    br(),
    
    # Add download button
    uiOutput(ns("downloadVolcanoPlotButtonUI")),
    #downloadButton(ns("downloadVolcanoPlot"), "Download Volcano Plot as PNG"),
    
    br(),
    
    
    add_busy_spinner(spin = "fading-circle", margins = c(10, 10), color = "blue", position = "bottom-left"),
    
    # Conditional Output for Volcano Plot
    conditionalPanel(
      condition = sprintf("input['%s'] == 'Differential Expression'", ns("analysisType")),
      plotOutput(ns("volcanoPlot"), height = "500px")
    )
    
    
  )
}