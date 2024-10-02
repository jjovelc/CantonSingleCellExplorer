# globals.R
library(shiny)
library(shinydashboard)
library(shinythemes)
library(Seurat)
library(markdown)
library(scales)
library(ggplot2)
library(RColorBrewer)
library(DT)
library(futile.logger)
library(shinycssloaders)
library(shinyjs)
library(shinybusy)

options(shiny.maxRequestSize = 5000*1024^2)

# Define viridis color palettes
my_palettes <- list(
  "Grey-Red"   = colorRampPalette(c("#D3D3D3", "#FF0000"))(256),
  "Grey-Blue"  = colorRampPalette(c("#D3D3D3", "#0000FF"))(256),
  "Grey-Green" = colorRampPalette(c("#D3D3D3", "#32CD32"))(256),
  "YlOrRd"     = brewer.pal(9, "YlOrRd")[3:9],
  "YlOrBr"     = brewer.pal(9, "YlOrBr")[3:9],
  "YlGnBu"     = brewer.pal(9, "YlGnBu")[3:9],
  "YlGn"       = brewer.pal(9, "YlGn")[3:9],
  "Reds"       = brewer.pal(9, "Reds")[3:9],
  "RdPu"       = brewer.pal(9, "RdPu")[3:9],
  "Purples"    = brewer.pal(9, "Purples")[3:9],
  "PuRd"       = brewer.pal(9, "PuRd")[3:9],
  "PuBuGn"     = brewer.pal(9, "PuBuGn")[3:9],
  "PuBu"       = brewer.pal(9, "PuBu")[3:9],
  "OrRd"       = brewer.pal(9, "OrRd")[3:9],
  "Oranges"    = brewer.pal(9, "Oranges")[3:9],
  "Greys"      = brewer.pal(9, "Greys")[3:9],
  "Greens"     = brewer.pal(9, "Greens")[3:9],
  "GnBu"       = brewer.pal(9, "GnBu")[3:9],
  "BuPu"       = brewer.pal(9, "BuPu")[3:9],
  "BuGn"       = brewer.pal(9, "BuGn")[3:9],
  "Blues"      = brewer.pal(9, "Blues")[3:9]
)

palette_names <- names(my_palettes)

# Modify loadSeuratObject to accept a filename
loadSeuratObject <- function(filename) {
  setwd('/Users/juanjovel/OneDrive/jj/UofC/data_analysis/jonathanCanton/')
  readRDS(filename)
}