#' tour
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#' @importFrom cicerone Cicerone
#' @export
#' @noRd

#
 guided_tour <- function(){
#

  cicerone::Cicerone$
  new(allow_close = TRUE)$
  step(
      "[data-value='INTERACTIVE MAPS']",
      "Main TAB",
      "Use this tab for interactive maps and assessing ranked variation within Admin2",
      is_id = FALSE
  )$
  step(
       el =  ".plot_tour",
       title = "Admin 3 Ranked variation",
       description = "Plot showing ranked variation of Admin-3 within Admin-2. Click on any interactive map polygon to assess the varaition within...",
       is_id = FALSE,
       position = "right",

  )$
  step(
    el =  ".admin_tour",
    title = "Switch Admin levels",
    description = "Use this Input to switch between admin2 and admin3",
    is_id = FALSE,
    position = "left"
  )$
  step(
    el =  ".var_tour",
    title = "Switch among disaster risk variables",
    description = "Use this Input to choose among available variables",
    is_id = FALSE,
    position ="left"
    )$
  step(
    el =  ".bin_tour",
    title = "Change the number of color bins",
    description = "Use this slider to customize the number of colorbins based on the quantiles of distribution. For instance, when 5 bins are selcted, each bin represents 20% of the data",
    is_id = FALSE,
    position = "left"
  )$
  step(
    el =  ".leaf_main",
    title = "Interactive Map",
    description = "Map will be updated here based on the selction",
    is_id = FALSE,
    position = "left"
  )$
  step(
    "[data-value='COMPARISON MAPS']",
    "Spatial comparison",
    "Use this tab for comparison across various indicators side by side.",
    is_id = FALSE,
    position = "bottom"
  )$
     step(
       "[data-value='INDEXING']",
       "Data-Driven Spatial Targeting",
       "Use this tab for constructing indices based on Principal Component Analysis algorithm to better inform spatial targeting",
       is_id = FALSE,
       position = "bottom"
     )
 }

 guided_tour_pca <- function(){
   #

   cicerone::Cicerone$
     new(allow_close = TRUE)$
     step(
       el =  ".pca_vars",
       title = "Select variables for PCA scores",
       description = "PCA scores will be calculated based on selected variables and shown on the interactive maps. User can select or deselect any variables to interchange among many possible options",
       is_id = FALSE,
       position = "right"
     )$
     step(
       el =  ".variance",
       title = "Percentage of variance explained by first 5 Principal components",
       description = "On the map, we show first principal component. The relatively better combination of variables will have higher variance explained in terms of PC1",
       is_id = FALSE,
       position = "right"
     )$
     step(
       el =  ".pca_download",
       title = "Download current PCA scores",
       description = "PCA scores can be downloaded in excel format for further use and validation",
       is_id = FALSE,
       position = "right"
     )$
     step(
       el =  ".bins_pca",
       title = "Change the number of colorbins for PCA visualization",
       description = "Use this input to customize the number of colorbins based on the quantiles of PCA distribution. For instance, when 5 bins are selcted, each bin represents 20% of the data",
       is_id = FALSE,
       position = "right"
     )$
     step(
       el =  ".pca_map",
       title = "Interactive Map",
       description = "Map will show updated index here based on the user selction",
       is_id = FALSE,
       position = "left"
     )


}

