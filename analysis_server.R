# modules/analysis_server.R

analysis_server <- function(input, output, session, obj) {
  ns <- session$ns
  
  # Reactive value to track whether analysis has been executed
  analysisExecuted <- reactiveVal(FALSE)
  
  # Reactive value to store the current analysis results
  analysisResults <- reactiveVal(NULL)
  
  observeEvent(input$executeAnalysis, {
    req(obj)
    
    if (input$analysisType == "Summary") {
      # Render the analysis output as a data table
      output$analysisOutput <- renderDT({
        req(obj)
        
        # Prepare the data
        sample_ids <- unique(obj()@meta.data$Sample_ID)
        feature_summary <- capture.output(summary(obj()@meta.data$nFeature_RNA))
        count_summary <- capture.output(summary(obj()@meta.data$nCount_RNA))
        mt_summary <- capture.output(summary(obj()@meta.data$percent.mt))
        cell_types <- unique(obj()@meta.data$cell_type)
        
        # Combine the data into a data frame
        analysis_data <- data.frame(
          Metric = c("Samples", "Feature Summary", "Count Summary", "Mitochondrial Summary", "Cell Types"),
          Value = c(
            paste(sample_ids, collapse = ", "),
            paste(feature_summary, collapse = "; "),
            paste(count_summary, collapse = "; "),
            paste(mt_summary, collapse = "; "),
            paste(cell_types, collapse = ", ")
          ),
          stringsAsFactors = FALSE
        )
        
        # Return the data frame as a data table
        datatable(analysis_data, options = list(pageLength = 5, autoWidth = TRUE))
      })
      
    # Code for producing list of marker genes  
    } else if (input$analysisType == "Find Markers") {
      
      # Ensure n_markers is an integer
      n_markers <- as.integer(input$n_markers)
      
      output$analysisOutput <- renderDT({
        withProgress(message = 'Finding markers...', value = 0, {
          
          clusters <- sort(unique(Idents(obj()))) 
          n_clusters <- length(clusters)
          all_markers <- data.frame()
          
          for (i in seq_along(clusters)) {
            cluster <- clusters[i]
            incProgress(1/n_clusters, detail = paste("Processing cluster", as.numeric(cluster) - 1))
            cluster.de.markers <- FindMarkers(obj(), ident.1 = cluster, ident.2 = NULL, only.pos = TRUE, min.pct = 0.1, logfc.threshold = 0.25)
            cluster.de.markers.sorted <- cluster.de.markers[order(cluster.de.markers$avg_log2FC, decreasing = TRUE),]
            cluster.de.markers.sorted <- as.data.frame(cluster.de.markers.sorted)
            df <- as.data.frame(head(cluster.de.markers.sorted, n=n_markers))
            df$cluster_number <- rep(i, n_markers)
            df$cell_type <- rep(cluster, n_markers) 
            all_markers <- rbind(all_markers, df)
          }
          analysisResults(all_markers)  # Store the results
          analysisExecuted(TRUE)  # Set to TRUE after analysis is executed
          
          datatable(all_markers, 
                    options = list(pageLength = -1, 
                                   autoWidth = TRUE,
                                   scrollY = "500px",  
                                   scrollCollapse = TRUE))  
        })
      })
    }
  })
  
  # Dynamic UI for download button
  output$downloadButtonUI <- renderUI({
    if (analysisExecuted()) {
      downloadButton(ns("downloadData"), "Download Results", class = "custom-download-button")
    }
  })
  
  
  # Dynamic UI for download button
  output$downloadButtonUI <- renderUI({
    if (analysisExecuted()) {
      downloadButton(ns("downloadData"), "Download Results")
    }
  })
  
  # Add this download handler
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("analysis-results-", Sys.Date(), ".tsv")
    },
    content = function(file) {
      data <- analysisResults()
      if (!is.null(data) && nrow(data) > 0) {
        write.table(data, file, sep = "\t", row.names = FALSE)
      } else {
        # Write an empty CSV with a message if there's no data
        write.csv(data.frame(Message = "No data available"), file, row.names = FALSE)
      }
    }
  )
  
  
}

          
 
