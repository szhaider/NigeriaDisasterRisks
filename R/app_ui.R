#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @importFrom cicerone use_cicerone
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),

    # guided tour

    # waiter::use_waiter(),
    # waiter::spin_chasing_dots(),
    # waiter::waiter_show_on_load(html = spin_loaders(10)),
    # Your application UI logic
    # fluidPage(
      # "NigeriaDisasterRisks",
    tagList(
      shiny::navbarPage(
        title = "NIGERIA CLIMATE RISKS",

        header = list(cicerone::use_cicerone()),
        id = "nav",

        # fluid = TRUE,
        # theme = shinythemes::shinytheme("journal"),  #This is nice

        # header=tags$style(HTML(".container-fluid{
        #                          padding: 3px !important;}
        #                          .navbar{
        #                          margin-bottom: 0px !important;
        #                          margin-left: 1px !important;}")),

        # shiny::tabPanel("INTRO"),
        shiny::tabPanel(
         "INTERACTIVE MAPS",
         # cicerone::use_cicerone(),
          mod_main_map_ui("main_map_1")
        ),

        shiny::tabPanel(
          "COMPARISON MAPS",
          mod_comp_maps_ui("comp_maps_1")
        ),

        tabPanel(
          "INDEXING",
           mod_pca_indexing_ui("pca_indexing_1")
        ),

        shiny::tabPanel(
          "SCATTER",
          mod_scatter_ui("scatter_1")
        )

    )
   )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js  bundle_resources
#' @noRd
golem_add_external_resources <- function() {


  addResourcePath('www', system.file('app/www', package = 'NigeriaDisasterRisks'))

  tags$head(
    golem::activate_js(),
    tags$script(type="text/javascript", src = "wb_img.js")
  )

  tags$head(
    includeCSS(path =  "inst/app/www/custom.css")
    )

  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    # favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "NigeriaDisasterRisks"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
