#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  # Your application server logic
  #Main Maps
  mod_main_map_server("main_map_1")
  #Comparison Maps
  mod_comp_maps_server("comp_maps_1")
  #Scatters
  mod_scatter_server("scatter_1")
}
