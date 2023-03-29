#' pca_indexing UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList

#'
mod_pca_indexing_ui <- function(id){
  ns <- NS(id)
  tagList(
    sidebarLayout(
      sidebarPanel(

        id = "sidebar-panel",

        width = 4,

        tags$strong(tags$em(tags$h6("Select the features to compute the Geographic Targeting Index based on Principal Component Analysis (PC1)"))),

        div(
          class= "pca_vars",
         shinyWidgets::pickerInput(ns("features_selected"),
                                  "Select featues for PCA",
                                  choices =  indicator_listed_adm2,
                                  selected = unlist(indicator_listed_adm2)[1:30],
                                  options = list(`live-search` = TRUE,
                                                   `dropdown-align-right` = 'auto',
                                                    style =  "my-pickerinput" ,
                                                     size = 10,
                                  `actions-box` = TRUE),
                                  multiple=TRUE)
         ),

        br(),

        div(class= "variance",
        shiny::plotOutput(ns("var_explained_pcs"),
                          height = "200px",
                          width = '100%')
        ),
        br(),

        div(class = "bins_pca",
        shiny::numericInput(ns("bins_pca"),
                     "Choose Number of Bins",
                     value = 5,
                     min=3,
                     max = 20,
                     step = 1)
        ),

        # br(),

        div(class= "pca_download",
        shiny::fluidRow(shiny::downloadLink(ns("pca_download"),
                                            "Download PCA (xlsx)",
                                            icon= icon("download"),
                                            class = "btn-sm"))
                        ),
        h6(actionLink(ns("pca_explained"),
                      "What are the PCA Scores?")),
        h6(actionLink(ns("pca_interpret"),
                      "How should the PCA scores be interpreted?")),
        br(),

        shiny::actionButton(ns("guide_pca"), "Tour around PCA index!", class = "btn-success")
        ),

      shiny::mainPanel(
        id = "main-page-panel",
        width = 8,

        div(class= "pca_map",
        leaflet::leafletOutput(ns("pca_map"),
                               width = "67vw"
            )
        )
      )
      )
    )
}

#' pca_indexing Server Functions
#'
#' @noRd
mod_pca_indexing_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    guided_tour_pca()$init()$start()

    observeEvent(input$guide_pca,{

    guided_tour_pca()$init()$start()

    })

    #Lealfet static options
    output$pca_map <- leaflet::renderLeaflet({
      leaflet::leaflet(options = leaflet::leafletOptions(zoomSnap = 0.20, zoomDelta = 0.20)) %>%
        leaflet::addProviderTiles(provider =  "CartoDB.Voyager", group = "CARTO") %>%
        leaflet::fitBounds(country_bounds[[1]], country_bounds[[2]], country_bounds[[3]], country_bounds[[4]]) %>%
        leaflet::setView(lng=9.5, lat = 9, zoom = 6) #
    })

    outputOptions(output, "pca_map", suspendWhenHidden = FALSE, priority = 1000)

    #Script for running Principal Component Analysis and prepping admin2 level standing in PC planes

    #If no NAs in the selected columns, as it is calculation. Otherwise removing NAs

    data_pca_final <- shiny::reactive({

      req(input$features_selected)

      data_pca_updated <-
        wide_data %>%
        dplyr::select(ADM2_NAME,
                      ADM2_CODE,
                      input$features_selected)

      if(any(is.na(data_pca_updated))) {
        data_pca_updated <- data_pca_updated %>%
          na.omit()
      }else{
        data_pca_updated
      }
    })


    #Recipe for algorithm
    #ADMIN2 as ID,
    #Normalizing predictors to compare variability across disparate features
    #PCA step
    pca_rec <- shiny::reactive({
      recipes::recipe(~., data = data_pca_final()) %>%
        recipes::update_role(ADM2_CODE, new_role = "id") %>%
        recipes::step_normalize(recipes::all_numeric_predictors()) %>%
        recipes::step_pca(recipes::all_numeric_predictors())
    })


    #Prepping PCA Recipe to execute steps

    pca_prep <- shiny::reactive({
      recipes::prep(pca_rec())
    })


    #Getting contribution of features to respective PCAs
    tidied_pca <- shiny::reactive({
      recipes::tidy(pca_prep(), 2)
    })

    #Admin2 level PCA scores
    pca_scores <- shiny::reactive({
      recipes::juice(pca_prep())
    })


    #To put omitted districts as NAs for Maps (Mostly no NAs in this data)
    admins_for_nas <- shiny::reactive({
      ADM2_CODES
    })


    na_admins <- shiny::reactive({
      admins_for_nas() %>%         ##As a function insert
        dplyr::anti_join(pca_scores()) %>%
        dplyr::mutate(PC1 = NA)
    })


    #Updated pca score with NA districts scores as NAs
    pca_scores_updated <- shiny::reactive({
      pca_scores() %>%
        dplyr::bind_rows(na_admins()) %>%
        dplyr::arrange(ADM2_CODE)
    })


    #Data for Maps
    map_data_pca <- shiny::reactive({
      pca_scores_updated()
    })



    #Labelling
    labels_pca_map <- reactive({
      paste0(glue("<b>ADM2_NAME</b>: { nig_shp_adm2$ADM_NAME } </br>"),
             glue("<b>Weighting scheme: </b> Principal Component Analysis (1)"), "<br/>",
             glue("<b>PCA score:</b> { round(map_data_pca()$PC1, 4)  }"),sep= "") %>%
             # glue("{ round(map_data_pca()$PC1, 4)  }"), sep = "") %>%
        lapply(htmltools::HTML)
    })


    pal_new_pca <- reactive({
      req(input$bins_pca)
      rev(colorRampPalette(colors = c('#2c7bb6', '#abd9e9', '#ffffbf', '#fdae61', '#d7191c'),
                           space = "Lab")(input$bins_pca))
    })


    #breaks defined
    breaks_pca <- reactive({
      req(input$bins_pca)
      quantile(map_data_pca()$PC1, seq(0, 1, 1 / (input$bins_pca)), na.rm = TRUE) %>%
        unique()
    })


    pal_pca <- reactive ({
      leaflet::colorBin(palette =  pal_new_pca(),

                        bins = breaks_pca(),
                        na.color = "grey",
                        domain = NULL,
                        map_data_pca()[,"PC1"],
                        pretty = F,
                        reverse=T
      )

    })

    # Pal_legend
    pal_leg_pca <- reactive ({
      leaflet::colorBin(palette = pal_new_pca(),
                        bins= breaks_pca(),
                        na.color = "grey",
                        domain =(map_data_pca()[,"PC1"]),
                        pretty = F,
                        reverse=T

      )
    })


  #Leaflet
    observe({

      req(input$bins_pca) || req(input$features_selected)

      leaflet::leafletProxy("pca_map",
                            data = nig_shp_adm2,
                            deferUntilFlush = TRUE) %>%
        leaflet::removeControl("legend") %>%
        leaflet::clearShapes() %>%
        leaflet::addPolygons(label= labels_pca_map(),
                             labelOptions = leaflet::labelOptions(
                               style = list("font-weight"= "normal",
                                            padding= "3px 8px",
                                            "color"= "black"),
                               textsize= "10px",
                               direction = "auto",
                               opacity = 0.9

                             ),
                             fillColor =  ~pal_pca()(map_data_pca()$PC1),
                             fillOpacity = 1,
                             stroke = TRUE,
                             color= "#5C4033",
                             weight = 1.5,
                             opacity = 1,
                             fill = TRUE,
                             dashArray =  c(3,3),
                             smoothFactor = 1,
                             highlightOptions = leaflet::highlightOptions(weight= 2.5,
                                                                          color = "black",
                                                                          fillOpacity = 1,
                                                                          opacity= 1,
                                                                          bringToFront = TRUE),
                             group = "Polygons")


      labels_pca_legend <- stringr::str_c("Priority", " ", seq(1, input$bins_pca))  %>%
        rev()

      labels_pca_legend[[length(labels_pca_legend)]] <-
        stringr::str_c(labels_pca_legend[[length(labels_pca_legend)]]," ", "(top priority)")

      if(any(is.na(map_data_pca()$PC1))){
        labels_pca_legend <- append("No data (NA)", labels_pca_legend)
      }

      if(any(is.na(map_data_pca()$PC1))){
        pal_new_pca_updated <- reactive(append(pal_new_pca(), "grey"))
      }else{
        pal_new_pca_updated <- reactive(pal_new_pca())
      }


      leaflet::leafletProxy("pca_map", data= map_data_pca()) %>%

        leaflet::clearControls() %>%
        leaflet::addLegend("bottomright",

                           values= map_data_pca()$PC1,
                           colors = (pal_new_pca_updated()),
                           labels = rev(labels_pca_legend),
                           title = "PCA Scores",
                           opacity= 1,
                           layerId = "legend")




})

    #Plot for PCs
    #By final 5 PCs juiced up

    output$var_explained_pcs <- shiny::renderPlot({

      min_vars_for_var_exp <-  (input$features_selected)

      shiny::validate(
        shiny::need(!is.null(min_vars_for_var_exp), "Choose atleast one variable in the first tab for the chart to show up!")
      )

      sdev_id <- function(){
        pca_scores() %>%
          dplyr::select(-ADM2_CODE, -ADM2_NAME) %>%
          purrr::map_df(., purrr::possibly(var, NA_integer_)) %>%
          tidyr::pivot_longer(everything(), names_to = "component", values_to = "value") %>%
          # group_by(component) %>%
          dplyr::mutate(
            percent_var = value/sum(value),
            cumsum = sum(percent_var))
      }

      sdev_id()  %>%
        # mutate(component = forcats::fct_reorder(factor(component), percent_var)) %>%
        ggplot2::ggplot(ggplot2::aes(component, percent_var))+
        ggplot2::geom_col(alpha=0.5, fill = "seagreen", width = 0.4)+
        # geom_point(aes(component,percent_var))+
        ggplot2::labs(x="Principal Components",
                      y="Variane Explained")+
        ggplot2::scale_y_continuous(labels = scales::percent_format())+
        theme(
          axis.line = element_line(color='black'),
          plot.background = element_blank(),
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_blank())
    })



    # PCA download
    output$pca_download <- downloadHandler(
      filename = function(){
        paste0("PCA Scores", ".csv")
      },
      content = function(file){
        write.csv(map_data_pca(), file)
      }

    )



################################################################################
    #PCA Index
    ##############################################.
    #### Modal  ----
    ###############################################.
    shiny::observeEvent(input$pca_explained, {
      shiny::showModal(modalDialog(
        title = "What are the PCA scores?",
        p("The PCA scores are calculated using Principal Component Analysis algorithm, to develop deeper insights into spatial variations based on user-selected criteria."),
        p("The purpose of this exercise is to ensure that a data-driven methodology is used to inform geographic targeting instead of subjectively assigning weights to various variables."),
        p("The user can choose any combination of given variables in the dataset to help prioritize/deprioritize admins at the lowest granularity in the country to optimize allocation of limited resources."),
        size = "m", easyClose = TRUE, fade=FALSE,footer = modalButton("Close (Esc)")))
    })


    shiny::observeEvent(input$pca_interpret, {
      shiny::showModal(modalDialog(
        title = "How should the PCA scores be interpreted?",
        p("The calculated PCA scores are shown on the map in terms of customizable qunatiles. For instance, when 5 bins are selected, each color-bin represents 20% of the data on the map."),
        p("The top priroty admins are the ones with highest PCA scores based on user-selected variables."),
        size = "m", easyClose = TRUE, fade=FALSE,footer = modalButton("Close (Esc)")))
    })
################################################################################

    })
}

## To be copied in the UI
# mod_pca_indexing_ui("pca_indexing_1")

## To be copied in the server
# mod_pca_indexing_server("pca_indexing_1")
