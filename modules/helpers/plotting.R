# This module contains functions for creating plots

make_violin_plot <- function(seurat_object, list_of_features) {
  plot <- VlnPlot(seurat_object, features = list_of_features)
  return(plot)
}

make_scatter_plot <- function(seurat_object, feat1, feat2){
  plot <- FeatureScatter(seurat_object, feature = feat1, feature2 = feat2)
  return(plot)
}

make_variable_features <- function(seurat_object) {
  seurat_object <- FindVariableFeatures(seurat_object, selection.method = "vst", nfeatures = 2000)
  # Identify the 10 most highly variable genes
  top10 <- head(VariableFeatures(seurat_object), 10)
  
  # plot variable features with and without labels
  plot1 <- VariableFeaturePlot(seurat_object)
  plot2 <- LabelPoints(plot = plot1, points = top10, repel = TRUE)
  return(plot1, plot2)
}

make_dimLoadings_plot <- function(seurat_object){
  plot <- VizDimLoadings(seurat_object, dims=1:2, reduction="pca")
  return(plot)
}

make_dimHeatmap_plot <- function(seurat_object, dimensions){
  plot <- DimHeatmap(seurat_object, dims = dimensions, cells = 500, balanced = TRUE)
}

make_elbow_plot <- function(seurat_object, num_dims = 20) {
  # Check if PCA has been run
  if (!"pca" %in% names(seurat_object@reductions)) {
    seurat_object <- RunPCA(seurat_object)
  }
  
  plot <- ElbowPlot(seurat_object, ndims = num_dims)
  return(plot)
}

# Define plotting functions inside the server function
make_feature_plot <- function(seurat_obj, inputGene, colors) {
  plot <- FeaturePlot(seurat_obj, features = inputGene, reduction = "umap", cols = colors)
  return(plot)
}

make_umap_plot <- function(seurat_obj, group_by) {
  plot <- DimPlot(seurat_obj, reduction = "umap", group.by = group_by, label = TRUE, pt.size = 1)
  return(plot)
}

make_ridge_plot <- function(seurat_object, features, group.by, ncol){
  plot <- RidgePlot(seurat_object, features = features, group.by = group.by, ncol = length(features))
  return(plot)
}

make_dot_plot <- function(seurat_object, features, group.by){
  plot <- DotPlot(seurat_object, features = features, group.by = group.by) + RotatedAxis()
  return(plot)
}

