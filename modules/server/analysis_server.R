# modules/analysis_server.R

analysis_server <- function(input, output, session, obj) {
  ns <- session$ns
  
  # Reactive values
  volcanoPlotObject <- reactiveVal(NULL)
  analysisExecuted <- reactiveVal(FALSE)
  analysisResults <- reactiveVal(NULL)
  showScrollMessage <- reactiveVal(FALSE)
  
  # Observe when analysisType changes to reset outputs
  observeEvent(input$analysisType, {
    # Reset reactive values
    analysisResults(NULL)
    analysisExecuted(FALSE)
    volcanoPlotObject(NULL)
    showScrollMessage(FALSE)
  
  })
  
  observeEvent(list(input$analysisType, input$deTest), {
    # Reset reactive values
    analysisResults(NULL)
    analysisExecuted(FALSE)
    volcanoPlotObject(NULL)
    showScrollMessage(FALSE)
  })
  

  
  # Observe the executeAnalysis button
  observeEvent(input$executeAnalysis, {
    req(obj())  # Ensure that 'obj' is available and reactive
    
    show_spinner() 
    
    if (input$analysisType == "Summary") {
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
      
      # Store the results
      analysisResults(analysis_data)
      analysisExecuted(TRUE)
      
    } else if (input$analysisType == "Find Markers") {
      # Ensure n_markers is an integer
      n_markers <- as.integer(input$n_markers)
      
      # Perform analysis
      withProgress(message = 'Finding markers...', value = 0, {
        clusters <- sort(unique(Idents(obj())))
        n_clusters <- length(clusters)
        all_markers <- data.frame()
        
        for (i in seq_along(clusters)) {
          cluster <- clusters[i]
          incProgress(1 / n_clusters, detail = paste("Processing cluster", cluster))
          cluster.de.markers <- FindMarkers(
            obj(),
            ident.1 = cluster,
            ident.2 = NULL,
            only.pos = TRUE,
            min.pct = 0.1,
            logfc.threshold = 0.25
          )
          cluster.de.markers.sorted <- cluster.de.markers[order(cluster.de.markers$avg_log2FC, decreasing = TRUE), ]
          cluster.de.markers.sorted <- as.data.frame(cluster.de.markers.sorted)
          df <- head(cluster.de.markers.sorted, n = n_markers)
          df$cluster_number <- i
          df$cell_type <- cluster
          all_markers <- rbind(all_markers, df)
        }
      })
      
      # Store the results
      analysisResults(all_markers)
      analysisExecuted(TRUE)
      
    } else if (input$analysisType == "Differential Expression") {
      # Ensure DE test method is selected
      req(input$deTest)
      
      # Perform DE analysis
      withProgress(message = 'It may take a couple of mins... be patient', value = 0, {
        # Identify the two classes in orig.ident
        classes <- unique(obj()@meta.data$orig.ident)
        req(length(classes) == 2)  # Ensure there are exactly two classes
        
        # Update progress
        incProgress(0.1, detail = "Preparing data...")
        
        # Copy the Seurat object
        obj_copy <- obj()
        Idents(obj_copy) <- obj_copy@meta.data$orig.ident
        
        # Select DE test method
        de_test <- switch(input$deTest,
                          "Wilcoxon" = "wilcox",
                          "T-test"   = "t",
                          "Bimod"    = "bimod",
                          "Poisson"  = "poisson",
                          "ROC"      = "roc",
                          "NegBinom" = "negbinom",
                          "LR"       = "LR",
                          "MAST"     = "MAST",
                          "wilcox")  # Default to Wilcoxon if not matched
        
        # Update progress
        incProgress(0.2, detail = "Running DE analysis...")
        
        # Perform DE analysis
        de.markers <- FindMarkers(
          obj_copy,
          ident.1 = classes[1],
          ident.2 = classes[2],
          test.use = de_test,
          only.pos = FALSE,
          min.pct = 0.1,
          logfc.threshold = 0.25
        )
        
        # Update progress
        incProgress(0.6, detail = "Processing results...")
        
        # Check if any markers are found
        if (nrow(de.markers) == 0) {
          showNotification("No differentially expressed genes found.", type = "warning")
          analysisResults(NULL)
          analysisExecuted(FALSE)
          return(NULL)
        }
        
        # Add gene names as a column
        de.markers$gene <- rownames(de.markers)
        de.markers <- de.markers[, c("gene", setdiff(names(de.markers), "gene"))]
        
        # Store the results
        analysisResults(de.markers)
        analysisExecuted(TRUE)
        
        # Update progress
        incProgress(0.1, detail = "Rendering table...")
      })
      
      # Notify that the analysis has completed
      showNotification("Differential Expression Analysis completed.", type = "message")
      
      if (de_test != "roc") {
        # Generate Volcano Plot
        output$volcanoPlot <- renderPlot({
          req(analysisExecuted())
          req(input$analysisType == "Differential Expression")
          req(analysisResults())
          
          de_data <- analysisResults()
          
          # Create the regulation column
          de_data$regulation <- "Not Significant"
          de_data$regulation[de_data$avg_log2FC > input$logFC_threshold & de_data$p_val_adj < input$pval_threshold] <- "Upregulated"
          de_data$regulation[de_data$avg_log2FC < -input$logFC_threshold & de_data$p_val_adj < input$pval_threshold] <- "Downregulated"
          
          # Create the volcano plot
          p <- ggplot(de_data, aes(x = avg_log2FC, y = -log10(p_val_adj), color = regulation)) +
            geom_point(alpha = 0.6, size = 2) +
            theme_minimal() +
            labs(title = "", x = "Log2 Fold Change", y = "-Log10 Adjusted P-value") +
            geom_vline(xintercept = c(-input$logFC_threshold, input$logFC_threshold), linetype = "dashed", color = "black") +
            geom_hline(yintercept = -log10(input$pval_threshold), linetype = "dashed", color = "black") +
            theme(plot.title = element_text(hjust = 0.5, size = 16, face = "bold"),
                  axis.title = element_text(size = 14)) +
            geom_text(data = subset(de_data, p_val_adj < input$pval_threshold & abs(avg_log2FC) > input$logFC_threshold),
                      aes(label = gene),
                      size = 3,
                      vjust = 1.5,
                      colour = "black",
                      check_overlap = TRUE) +
            scale_color_manual(values = c("Upregulated" = "red", "Downregulated" = "dodgerblue", "Not Significant" = "darkgrey"))
          
          # Store the plot in a reactive value for downloading
          volcanoPlotObject(p)
          
          # Print the plot
          print(p)
        })
        
        # Dynamic UI for download buttons
        output$downloadButtonUI <- renderUI({
          if (analysisExecuted()) {
            downloadButton(ns("downloadData"), "Download Results")
          }
        })
        
        output$downloadVolcanoPlotButtonUI <- renderUI({
          if (analysisExecuted() && !is.null(volcanoPlotObject())) {
            downloadButton(ns("downloadVolcanoPlot"), "Download Volcano Plot")
          }
        })
        
        # Set the scroll message to be shown
        showScrollMessage(TRUE)
        
        # Download handler for volcano plot
        output$downloadVolcanoPlot <- downloadHandler(
          filename = function() {
            paste0("VolcanoPlot-", Sys.Date(), ".png")
          },
          content = function(file) {
            req(volcanoPlotObject())
            ggsave(
              filename = file,
              plot = volcanoPlotObject(),
              device = "png",
              width = 8,
              height = 6,
              units = "in",
              bg = "white"
            )
          }
        )
        
      } else {
        # Generate ROC Plot
        output$volcanoPlot <- renderPlot({
          req(analysisExecuted())
          req(input$analysisType == "Differential Expression")
          req(analysisResults())
          
          roc_data <- analysisResults()
          
          # Create the ROC plot based on AUC values
          top_markers <- roc_data[order(roc_data$myAUC, decreasing = TRUE), ]
          
          # Plot the top 10 markers based on AUC values
          p <- ggplot(top_markers[1:10, ], aes(x = reorder(rownames(top_markers)[1:10], myAUC[1:10]), y = myAUC[1:10])) +
            geom_bar(stat = "identity", fill = "dodgerblue") +
            coord_flip() +
            theme_minimal() +
            labs(x = "Genes", y = "AUC", title = "Top 10 ROC Markers by AUC") +
            theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 14),  # Increase x-axis text size
                  axis.text.y = element_text(size = 14),                         # Increase y-axis text size
                  axis.title.x = element_text(size = 16),                        # Increase x-axis title size
                  axis.title.y = element_text(size = 16),                        # Increase y-axis title size
                  plot.title = element_text(hjust = 0.5, size = 18, face = "bold")) # Increase plot title size
          
          # Print the ROC plot
          print(p)
        })
        
        # No download button for volcano plot in this case, so remove it
        output$downloadVolcanoPlotButtonUI <- renderUI({
          NULL  # Hide the download button
        })
        
        # Set the scroll message to be hidden since it's not relevant for ROC
        showScrollMessage(FALSE)
      }
    }
    hide_spinner()
  })
  
  # Render the scroll message
  output$scrollMessage <- renderUI({
    if (showScrollMessage()) {
      tags$div(
        style = "color: blue; font-size: 16px; margin-bottom: 10px;",
        "Scroll down to see the volcano plot."
      )
    } else {
      NULL  # Return NULL to render nothing if the message should not be shown
    }
  })
  
  # Render the analysis output table
  output$analysisOutput <- renderDT({
    req(analysisExecuted())
    req(analysisResults())
    datatable(analysisResults(), 
              options = list(pageLength = 10, 
                             autoWidth = TRUE,
                             scrollY = "500px",  
                             scrollCollapse = TRUE))
  })
  
  
  
  # Download handler for analysis results
  output$downloadData <- downloadHandler(
    filename = function() {
      paste0("analysis-results-", Sys.Date(), ".tsv")
    },
    content = function(file) {
      data <- analysisResults()
      if (!is.null(data) && nrow(data) > 0) {
        write.table(data, file, sep = "\t", row.names = FALSE)
      } else {
        write.csv(data.frame(Message = "No data available"), file, row.names = FALSE)
      }
    }
  )
  
  
}