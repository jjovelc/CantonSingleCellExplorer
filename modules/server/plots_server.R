# modules/plots_server.R

plots_server <- function(input, output, session, obj) {
  ns <- session$ns
  
  message("Initializing plot server")
  
  observeEvent(obj(), {
    if (!is.null(obj())) {
      updateSelectizeInput(session, "gene", choices = rownames(obj()), server = TRUE)
      updateSelectizeInput(session, "ridgeGenes", choices = rownames(obj()), server = TRUE)
      updateSelectizeInput(session, "violinGenes", choices = rownames(obj()), server = TRUE)
      updateSelectizeInput(session, "dotGenes", choices = rownames(obj()), server = TRUE)
      
      # Update dimensions for DimHeatmap
      available_reductions <- names(obj()@reductions)
      if ("pca" %in% available_reductions) {
        num_dims <- ncol(Embeddings(obj(), reduction = "pca"))
        dimension_choices <- 1:num_dims
        
        # Set default selected dimensions
        default_selected_dims <- 1:6  # Or any other default dimensions you prefer
        
        # Ensure the default selected dimensions are within available dimensions
        default_selected_dims <- default_selected_dims[default_selected_dims <= num_dims]
        
        updateSelectizeInput(
          session,
          "dimensions",
          choices = dimension_choices,
          selected = default_selected_dims,
          server = TRUE
        )
      } else {
        # Handle case where PCA is not available
        updateSelectizeInput(session, "dimensions", choices = NULL, selected = NULL, server = TRUE)
      }
    }
  })
  
  # Store the plot object
  plot_object <- reactiveVal()
  
  # Update feat2 choices based on feat1 selection only when plotType is Scatter Plot
  observeEvent(input$feat1, {
    if (input$plotType == "Scatter Plot") {
      available_choices <- c("nCount_RNA", "nFeature_RNA", "percent.mt")
      updateSelectInput(session, "feat2", choices = setdiff(available_choices, input$feat1))
    }
  })
  
  # Update feat1 choices based on feat2 selection only when plotType is Scatter Plot
  observeEvent(input$feat2, {
    if (input$plotType == "Scatter Plot") {
      available_choices <- c("nCount_RNA", "nFeature_RNA", "percent.mt")
      updateSelectInput(session, "feat1", choices = setdiff(available_choices, input$feat2))
    }
  })
  
  output$plotOutput <- renderPlot({
    req(obj())
    plot <- NULL
    
    if (input$plotType == "UMAP") {
      if (input$groupBy == "gene") {
        req(input$gene)
        palette_name <- input$colorPalette
        start_break  <- input$startBreak
        colors <- my_palettes[[palette_name]]
        if (palette_name %in% names(my_palettes)) {
          colors <- colors[start_break:length(colors)]
        } else {
          colors <- brewer.pal(9, palette_name)[start_break:9]
        }
        # it works
        plot <- FeaturePlot(obj(), features = input$gene, reduction = "umap", cols = colors)
        
        
      } else {
        plot <- make_umap_plot(obj, input$groupBy)  
      }
    } else if (input$plotType == "Ridge Plot") {
      req(input$ridgeGenes)
      group.by <- input$ridgeGroupBy
      plot <- make_ridge_plot(obj, input$ridgeGenes, group.by, length(input$ridgeGenes))  
      
    } else if (input$plotType == "Elbow Plot") {
      plot <- make_elbow_plot(obj())
      
    } else if (input$plotType == "Violin Plot") {
      req(input$violinGenes)
      group.by <- input$violinGroupBy
      plot <- make_violin_plot(obj(), input$violinGenes)
      
    } else if (input$plotType == "DimHeatmap") {
      req(input$dimensions)
      dimensions <- as.numeric(input$dimensions)
      
      # Call the DimHeatmap function directly
      DimHeatmap(obj(), dims = dimensions, cells = 500, balanced = TRUE)
      
      # Note: DimHeatmap plots directly and does not return a plot object
      # So we do not assign it to 'plot' or 'plot_object'
      return()
      
    } else if (input$plotType == "Dot Plot") {
      dotGenes <- unique(c(input$dotGenes, unlist(strsplit(input$geneList, "[,\\s]+"))))
      req(dotGenes)
      group.by <- input$dotGroupBy
      plot <- DotPlot(obj(), features = dotGenes, group.by = group.by) + RotatedAxis()  
      
    } else if (input$plotType == "Scatter Plot") {
      req(input$feat1, input$feat2)
      
      # Retrieve the Seurat object by evaluating the reactive expression
      seurat_object_value <- obj()  # Make a local copy of the Seurat object
      
      # Calculate percent.mt if necessary
      if ("percent.mt" %in% c(input$feat1, input$feat2)) {
        seurat_object_value[["percent.mt"]] <- PercentageFeatureSet(seurat_object_value, pattern = "^MT-")
      }
      
      # Generate the scatter plot using the computed or selected features
      plot <- make_scatter_plot(seurat_object_value, input$feat1, input$feat2)
      
    }  else if (input$plotType == "Elbow Plot") {
      num_dims <- if (!is.null(input$numDims)) as.numeric(input$numDims) else 20
      plot <- make_elbow_plot(obj(), num_dims)
      plot_object(plot)
      print(plot)
    } 
    
    
    plot_object(plot)
    print(plot)
  }, width = 600, height = 600)  # Set width and height to keep it square
  
  output$downloadPlotPNG <- downloadHandler(
    filename = function() {
      paste("plot", Sys.Date(), ".png", sep = "")
    },
    content = function(file) {
      ggsave(file, plot = plot_object(), device = "png", width = 6, height = 6, units = "in")
    }
  )
}