#' scatter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#'
#'
mod_scatter_ui <- function(id){
  ns <- NS(id)
  tagList(

    sidebarLayout(
      sidebarPanel(width = 3,
        shinyWidgets::pickerInput(
          inputId = ns("description_1"),
          label = "Select a Variable: ",
          choices = indicator_listed_adm2,

          options = list(`live-search` = TRUE,
                         `dropdown-align-right` = 'auto',
                         style =  "my-pickerinput" ),
          choicesOpt = list(

            style = rep_len("font-size: 90%; line-height: 1.6;", 30))
        ),
        shinyWidgets::pickerInput(
          inputId = ns("description_2"),
          label = "Select a Variable: ",
          choices = indicator_listed_adm2,

          options = list(`live-search` = TRUE,
                         `dropdown-align-right` = 'auto',
                         style =  "my-pickerinput" ),
          choicesOpt = list(

            style = rep_len("font-size: 90%; line-height: 1.6;", 30))
        ),
      ),
      mainPanel(
        width = 9,

        shiny::plotOutput(ns("scatterplot"),
                          height = '600px')

      )
    )
  )
}

#' scatter Server Functions
#'
#' @noRd
mod_scatter_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    wide_data <- shiny::reactive({
    adm2_data %>%
      tidyr::pivot_wider(id_cols = c(ADM1_NAME, ADM2_NAME),
                         names_from = description,
                         values_from = value)

    })

    output$scatterplot <- shiny::renderPlot({

      xvar <- reactiveVal(input$description_1)
      yvar <- reactiveVal(input$description_2)

      # wide_data %>%
      #   ggplot(aes(`Relative Wealth Index`, `Relative Wealth Index`))+
      #   geom_point()

      # x=.data[[input$description_1]], y=.data[[input$description_2]]
      wide_data() %>%
        dplyr::select(ADM2_NAME, xvar(), yvar()) %>%
        ggplot2::ggplot(ggplot2::aes(.data[[xvar()]], .data[[yvar()]])) +
        ggplot2::geom_point()+
        ggplot2::theme_classic()
    })
  })
}

## To be copied in the UI
# mod_scatter_ui("scatter_1")

## To be copied in the server
# mod_scatter_server("scatter_1")
