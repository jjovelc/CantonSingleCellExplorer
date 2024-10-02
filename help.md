Canton Single Cell Explorer

========================================================================

Introduction

Welcome to the RShiny App for Analyzing Seurat Results! This interactive application allows you to visualize and analyze single-cell RNA sequencing data processed with the Seurat package. By inputting your own Seurat object (.RDS file), you can generate various plots and perform analyses such as finding marker genes and conducting differential expression analysis.

This guide will help you understand how to use the app, load your data, and make the most of its plotting and analysis capabilities.

Table of Contents

Requirements
Getting Started
Launching the App
Loading Your Data

Analysis Section

1. Summary
2. Find Markers
3. Differential Expression

Plots Section

1. UMAP
2. Ridge Plot
3. Violin Plot
4. Dot Plot
5. DimHeatmap
6. Elbow Plot
7. Scatter Plot

Downloading Results
Tips and Troubleshooting
Contact Information

Requirements

Before using the app in stand-alone mode, ensure you have the following:

R (version 4.0 or higher)
RStudio (recommended but not mandatory)

Required R packages:
shiny
Seurat
ggplot2
dplyr
plotly
DT
RColorBrewer
shinythemes
Other dependencies as required by the app

Note: Ensure all packages are up-to-date to avoid compatibility issues.

Getting Started

Launching the App
Download the App Files: Ensure you have all the necessary .R files for the app, including ui.R, server.R, and any module files (analysis_server.R, plots_server.R, etc.).

Set Working Directory: Open R or RStudio and set the working directory to the folder containing the app files.

R
Copy code
setwd("path/to/your/app/directory")
Run the App: Launch the app using the shiny::runApp() function.

R
Copy code
shiny::runApp()
Alternatively, in RStudio, you can click the "Run App" button in the top-right corner of the script editor.

Loading Your Data
The app requires a Seurat object saved as an .RDS file. This file should contain your processed single-cell RNA-seq data.

To load your data:

Prepare Your Seurat Object:

Ensure your Seurat object includes the necessary metadata and assays.
Common assays include RNA for raw counts and integrated if you have performed data integration.
Metadata should include variables like orig.ident, cell_type, seurat_clusters, etc.
Save Your Seurat Object:

R

Copy code

saveRDS(your_seurat_object, file = "your_seurat_object.rds")

Upload the RDS File in the App:

Once the app is running, look for drop-down menu "Select Seurat RDS File".

Click it and select your .RDS file.
Wait for the data to load. A confirmation message or summary should appear once the data is loaded successfully.

Analysis Section

Navigate to the "Analysis" tab in the app to access various analytical tools.

1. Summary
Provides a quick overview of your dataset.

How to Use:
Select Analysis Type: Choose "Summary" from the "Select Analysis" dropdown.
Execute Analysis: Click "Execute Analysis".
View Results: A table will display key metrics such as:
Sample IDs
Feature (gene) count summary
RNA count summary
Mitochondrial gene percentage summary
Unique cell types
Note: Use this to confirm that your data has been loaded correctly and to get an initial sense of its composition.

2. Find Markers
Identifies marker genes for each cluster in your data.

How to Use:
Select Analysis Type: Choose "Find Markers".
Set Number of Markers: Input the number of top markers you want per cluster (e.g., 10).
Execute Analysis: Click "Execute Analysis".
View Results: A table will display the top marker genes for each cluster, along with statistics like:
Average log fold change (avg_log2FC)
Adjusted p-values (p_val_adj)
Download Results: If desired, click "Download Results" to save the table as a TSV file.
Tip: Use this analysis to identify genes that are highly expressed in specific clusters, which can help in annotating cell types.

3. Differential Expression
Performs differential expression analysis between two groups.

Prerequisites:

Your Seurat object's metadata (meta.data) must contain the orig.ident field with exactly two unique classes/groups.

How to Use:
Select Analysis Type: Choose "Differential Expression".
Select DE Test Method: Choose from methods like Wilcoxon, T-test, MAST, etc.

Set Thresholds:
Log2 Fold Change Threshold: Minimum absolute log2 fold change to consider (e.g., 0.25).
Adjusted P-value Threshold: Significance level for adjusted p-values (e.g., 0.05).
Execute Analysis: Click "Execute Analysis".

View Results:
A table will display differentially expressed genes between the two groups.
Includes statistics like avg_log2FC, p_val_adj, etc.

Volcano Plot:
A volcano plot will be generated to visualize the DE results.
Significant genes beyond the set thresholds will be highlighted and labeled.
Download Results: Click "Download Results" to save the DE table.
Note: This analysis is useful for comparing gene expression between two conditions or treatments.

Plots Section
Navigate to the "Plots" tab to generate various visualizations.

1. UMAP
Visualizes cells in a reduced dimensional space (Uniform Manifold Approximation and Projection).

How to Use:
Select Plot Type: Choose "UMAP".

Group By:
seurat_clusters: Color cells by their assigned clusters.
cell_type: Color cells by cell type annotations.
gene: Color cells based on the expression of a selected gene.

Gene Expression:
If you choose "gene", select the gene of interest from the "Select Gene" dropdown.

Color Palette:
Choose a color palette for continuous expression values.
Adjust the "Intensity" to set the starting point of the color scale.

View Plot: The UMAP plot will display in the main panel.

Download Plot: Click "Download Plot as PNG" to save the visualization.

Tip: Use the UMAP plot to explore the overall structure of your data and identify clusters or expression patterns.

2. Ridge Plot
Displays the distribution of gene expression levels across clusters or cell types.

How to Use:
Select Plot Type: Choose "Ridge Plot".

Select Genes: Choose one or more genes to plot.

Group By: Select how to group cells (e.g., seurat_clusters, cell_type).

View Plot: The ridge plots will appear, showing expression distributions.

Download Plot: Save the plot using the download button.

Tip: Ridge plots are excellent for comparing the expression of genes across different groups.

3. Violin Plot
Shows the distribution of gene expression levels and allows comparison across groups.

How to Use:
Select Plot Type: Choose "Violin Plot".

Select Genes: Choose one or more genes.

Group By: Select the grouping variable.

View Plot: The violin plots will display.

Download Plot: Use the provided button to save your plot.

Tip: Violin plots combine box plots and kernel density plots, providing a detailed view of expression distributions.

4. Dot Plot
Visualizes expression levels of genes across different groups, with the size and color of dots representing expression levels and percentage of cells expressing the gene.

How to Use:
Select Plot Type: Choose "Dot Plot".
Select Genes:
Choose genes from the dropdown or
Paste a list of genes (comma or newline-separated) into the "Paste Genes for Dot Plot" text area.

Group By: Select the grouping variable.
View Plot: The dot plot will display.
Download Plot: Click the download button to save the plot.
Tip: Dot plots are useful for comparing multiple genes across several groups simultaneously.

5. DimHeatmap
Displays genes that define principal components or dimensions.

How to Use:
Select Plot Type: Choose "DimHeatmap".

Select Dimensions: Choose which principal components to display.

View Plot: The heatmap will render directly.

Download Plot: Use the download button if available.

Note: This plot helps in understanding the genes contributing to each principal component.

6. Elbow Plot
Helps determine the number of principal components to use by displaying the standard deviation of each principal component.

How to Use:
Select Plot Type: Choose "Elbow Plot".

Number of Dimensions: Set how many principal components to display (e.g., 20).

View Plot: The elbow plot will appear.

Download Plot: Save the plot if needed.

Tip: Look for the "elbow" point where the rate of decrease sharply changes, indicating a suitable number of dimensions to use.

7. Scatter Plot
Creates a scatter plot of two features (e.g., gene counts, mitochondrial percentage).

How to Use:
Select Plot Type: Choose "Scatter Plot".

Select Features:
Feature 1: Choose from nCount_RNA, nFeature_RNA, or percent.mt.
Feature 2: Select a different feature from the same list.

View Plot: The scatter plot will display.

Download Plot: Click the download button to save.

Tip: Scatter plots are useful for detecting correlations between features and identifying outliers.

Downloading Results
For analyses and plots that generate results or visualizations, the app provides download options.

Data Tables: After performing analyses like "Find Markers" or "Differential Expression", click "Download Results" to save the data as a TSV file.

Plots: Use the "Download Plot as PNG" button to save the current visualization.

Note: Ensure you have executed the analysis or generated the plot before attempting to download.

Tips and Troubleshooting
Data Compatibility:

Ensure your Seurat object is properly formatted and contains the necessary metadata fields (orig.ident, seurat_clusters, etc.).
The object should include the required assays and reductions (e.g., PCA, UMAP).
Gene Selection:

When selecting genes, use exact gene names as they appear in your dataset.
The gene selection inputs support autocomplete and searching.

Performance:

Large datasets may take longer to load and process.
Use the "withProgress" messages in the app to monitor the status of long-running tasks.
Errors and Warnings:

If an analysis returns no results (e.g., no differentially expressed genes found), the app will display a notification.
Ensure that all required inputs are provided; the app uses req() to enforce this.
Visualizations:

Some plots like DimHeatmap may render directly and not return a plot object. In these cases, the plot appears without being assigned to a variable.
Customize plots using available options (e.g., color palettes, grouping variables).
Dependencies:

If you encounter errors related to missing packages or functions, ensure all dependencies are installed and loaded.

The app uses custom color palettes and functions; make sure all required scripts and data are included.
Contact Information

If you have questions, encounter issues, or need assistance, please contact the app developer:

Name: Juan Jovel<br>
Email: juan.jovel@ucalgary.ca<br>
GitHub: https://github.com/jjovelc<br>
