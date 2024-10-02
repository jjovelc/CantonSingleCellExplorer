# modules/ui/plots_ui.R

plots_ui <- function(id) {
  ns <- NS(id)
  
  tagList(
    # CSS
    tags$head(
      tags$style(HTML("
        h3 {
          font-size: 26px;
        }
        .well {
          color: black;
          background-color: gray100;
        }
      "))
    ),
    sidebarLayout(
      sidebarPanel(
        selectInput(ns("plotType"), "Select Plot Type:", choices = c("UMAP", "Ridge Plot", "Scatter Plot", "Violin Plot", 
                                                                     "Dot Plot", "DimHeatmap", "Elbow Plot")),
        
        # UMAP plot
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Ridge Plot'", ns("plotType")),
          selectizeInput(ns("ridgeGenes"), "Select Genes for Ridge Plot:", choices = NULL, multiple = TRUE, 
                         options = list(placeholder = "Select or search gene names",
                                        maxOptions = 30000,
                                        searchConjunction = 'and')),
          selectInput(ns("ridgeGroupBy"), "Group By:", choices = c("seurat_clusters", "cell_type"))
        ), 
        
        conditionalPanel(
          condition = sprintf("input['%s'] == 'UMAP'", ns("plotType")),
          selectInput(ns("groupBy"), "Group By:", choices = c("seurat_clusters", "cell_type", "gene")),
          conditionalPanel(
            condition = sprintf("input['%s'] == 'gene'", ns("groupBy")),
            selectizeInput(ns("gene"), "Select Gene:", choices = NULL, multiple = TRUE,
                           options = list(placeholder = "Select or search gene name",
                                          maxOptions = 30000,
                                          searchConjunction = 'and')),
            selectInput(ns("colorPalette"), "Select Color Palette:", choices = palette_names),
            numericInput(ns("startBreak"), "Intensity (1-9):", value = 1, min = 1, max = 9, step = 1)
          )
        ),
        
        # DimHeatmap plot
        conditionalPanel(
          condition = sprintf("input['%s'] == 'DimHeatmap'", ns("plotType")),
          selectizeInput(ns("dimensions"), "Select Dimensions:", choices = NULL, multiple = TRUE)
        ),
        
        # Elbow plot
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Elbow Plot'", ns("plotType")),
          numericInput(ns("numDims"), "Number of Dimensions:", value = 20, min = 5, max = 30, step = 1)
        ),
        
        # Scatter plot
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Scatter Plot'", ns("plotType")),
          selectInput(ns("feat1"), "Select Feature 1", 
                      choices = c("nCount_RNA", "nFeature_RNA", "percent.mt")),
          selectInput(ns("feat2"), "Select Feature 2", 
                      choices = c("nCount_RNA", "nFeature_RNA", "percent.mt")),
          plotOutput(ns("scatter_plot"))
        ),
        
        # Violin plot
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Violin Plot'", ns("plotType")),
          selectizeInput(ns("violinGenes"), "Select Genes for Violin Plot:", choices = NULL, multiple = TRUE, 
                         options = list(placeholder = "Select or search gene names",
                                        maxOptions = 30000,
                                        searchConjunction = 'and')),
          selectInput(ns("violinGroupBy"), "Group By:", choices = c("seurat_clusters", "cell_type"))
        ),
        
        # Dot plot
        conditionalPanel(
          condition = sprintf("input['%s'] == 'Dot Plot'", ns("plotType")),
          selectizeInput(ns("dotGenes"), "Select Genes for Dot Plot:", choices = NULL, multiple = TRUE, 
                         options = list(placeholder = "Select or search gene names",
                                        maxOptions = 30000,
                                        searchConjunction = 'and')),
          textAreaInput(ns("geneList"), "Paste Genes for Dot Plot (comma or newline separated):", 
                        placeholder = "Enter genes separated by commas"),
          selectInput(ns("dotGroupBy"), "Group By:", choices = c("seurat_clusters", "cell_type"))
        ),
        width = 3
      ),
      
      
      
      mainPanel(
        downloadButton(ns("downloadPlotPNG"), "Download Plot as PNG"),
        width = 9,
        div(class = "square-plot-container",
            plotOutput(ns("plotOutput"), 
                       width = "600px", 
                       height = "600px")
        )
      )
      
    )
  )
}