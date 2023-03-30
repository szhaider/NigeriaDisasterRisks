#' comp_maps UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'@importFom leaflet.minicharts syncWith
#' @importFrom shiny NS tagList
mod_comp_maps_ui <- function(id){
  ns <- NS(id)
  tagList(

    tabPanel("COMPARISON MAPS",

             mainPanel(
               width = 12,

               fluidRow(

                 mainPanel(width = 6,
                        offset = 0,


                        # tags$style(type = 'text/css', "#comp_maps_1-double_map_1 {height: calc(100vh - 100px) !important;
                        # 'padding-bottom:0px;
                        #                padding-left:-20px;
                        #                padding-right:-20px;
                        #                margin-left:-20px;
                        #                 margin-right:-20px;
                        #                position: relative;}"),
                      leafletOutput(ns("double_map_1"),
                                    width = "49.5vw"
                                    ),

                            shiny::absolutePanel(
                            id = "controls_panel",
                            class = "panel panel-default",
                            fixed= TRUE,
                            draggable = FALSE,
                            bottom = "auto",
                            right = "auto", left = 6, top = 64,
                            width = 300, height = "auto",

                             # tags$style(".my-pickerinput {font-size: 70%; line-height: 1;}"), ###

                            shinyWidgets::pickerInput(
                              inputId = ns("description_comp1"),
                              label = "Select a Variable: ",
                              choices = indicator_listed_adm1,
                              options = list(`live-search` = TRUE,
                                             `dropdown-align-right` = 'auto',
                                             style = "my-pickerinput" ,
                                             size = 10
                                             ),

                              choicesOpt = list(style = rep_len("font-size: 70%; line-height: 1;", 30))
                            ),

                            shinyWidgets::pickerInput(
                              inputId = ns("polygon_comp1"),
                              label = "Select Admin level: ",
                              choices = c("Admin 1", "Admin 2"),
                              options = list(`dropdown-align-right` = 'auto',
                                             style = "my-pickerinput"),
                              choicesOpt = list(style = rep_len("font-size: 80%; line-height: 1;", 2))
                            ),

                            shiny::sliderInput(ns("bins_comp1"),
                                               label = "Choose number of Bins",
                                               min = 3,
                                               max= 10,
                                               value = 5,
                                               step=1),



                   )),
                   mainPanel(width = 6,
                          offset = 0,


                          # tags$style(type = "text/css', '#comp_maps_1-double_map_2 {height: calc(100vh - 100px) !important;
                          #            'padding-bottom:0px;
                          #              padding-left:0px;
                          #              padding-right:-10px;
                          #              margin-left:-10px;
                          #              position: relative;}"),
                       leaflet::leafletOutput(ns("double_map_2"),
                                              width = "49.5vw"),

                          shiny::absolutePanel(
                            id = "controls_panel",
                            class = "panel panel-default",
                            fixed= TRUE,
                            draggable = FALSE, bottom = "auto", left = "auto", right = 3, top = 64,
                            width = 300, height = "auto",

                            shinyWidgets::pickerInput(
                              inputId = ns("description_comp2"),
                              label = "Select a Variable: ",
                              choices = indicator_listed_adm1,

                              options = list(`live-search` = TRUE,
                                             `dropdown-align-right` = 'auto',
                                             style = "my-pickerinput",
                                             size = 10 ),
                              choicesOpt = list(

                              style = rep_len("font-size: 70%; line-height: 1;", 30))
                            ),
                            shinyWidgets::pickerInput(
                              inputId = ns("polygon_comp2"),
                              label = "Select Admin level: ",
                              choices = c("Admin 1", "Admin 2"),
                              options = list(`dropdown-align-right` = 'auto',
                                             style = "my-pickerinput" ),
                              choicesOpt = list(style = rep_len("font-size: 80%; line-height: 1;", 2))
                            ),

                            shiny::sliderInput(ns("bins_comp2"),
                                               label = "Choose number of Bins",
                                               min = 3,
                                               max= 10,
                                               value = 5,
                                               step=1)
                          )

                   )


             )


  ))
  )
}

#' comp_maps Server Functions
#'
#' @noRd
mod_comp_maps_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns


    ############################################################################

    #Shapes
    shps_comp1 <- shiny::reactive({

      req(input$polygon_comp1)

      if(input$polygon_comp1 == "Admin 2"){
        return(nig_shp_adm2)
      }else{
        return(nig_shp_adm1)
      }

    })

    ############################################################################
    #Map1
    already_selected_comp1 <- shiny::reactiveVal()

    observe({
      already_selected_comp1(input$description_comp1)
    })


    shiny::observeEvent(input$polygon_comp1, {

      choices_up_comp1 = reactive({
        if(input$polygon_comp1 == "Admin 2"){
          return(indicator_listed_adm2)
        }else{
          return(indicator_listed_adm1)
        }
      })

      freezeReactiveValue(input, "description_comp1")

        shinyWidgets::updatePickerInput(
        session = session,
        inputId = "description_comp1",
        label = "Select a Variable",
        choices = choices_up_comp1(),
        selected = already_selected_comp1()
      )


    })


    #Main Map
    #selecting variable
    map_data_comp1 <- shiny::reactive({
      if(input$polygon_comp1 == "Admin 2"){
        adm2_data %>%
          dplyr::filter(description == input$description_comp1)
      }else if(input$polygon_comp1 == "Admin 1"){
        adm1_data %>%
          dplyr::filter(description == input$description_comp1)

      }
    })


    #Bounds
    # country_bounds <-   nig_shp_adm0 %>% sf::st_bbox()

    #Lealfet static options
    output$double_map_1 <- leaflet::renderLeaflet({
      leaflet::leaflet(options = leaflet::leafletOptions(zoomSnap = 0.20, zoomDelta = 0.20)) %>%
        leaflet::addProviderTiles(provider =  "CartoDB.Voyager") %>%
        # leaflet::fitBounds(country_bounds[[1]], country_bounds[[2]], country_bounds[[3]], country_bounds[[4]]) %>%
        leaflet::setView(lng=11, lat = 13, zoom = 5) %>%
        leaflet.minicharts::syncWith("combined_map")
    })

    #To render leafelt map before proxy observer updates
    outputOptions(output, "double_map_1", suspendWhenHidden = FALSE)


    #Labelling for the Map
    labels_map_comp1 <- shiny::reactive({
      paste0(glue::glue("<b>Admin: { shps_comp1()$ADM_NAME } </b> </br>"),
             glue::glue("<b>Variable:</b> { map_data_comp1()$description }</br>"),
             glue::glue("<b>Value: <b/>  { round(map_data_comp1()$value, 3) }"),
             sep = "") %>%
        lapply(htmltools::HTML)
    })

    # breaks defined
    # breaks_comp1 <- shiny::reactive({
    #   stats::quantile(map_data_comp1()$value, seq(0, 1, 1 / (input$bins_comp1)), na.rm = TRUE) %>%
    #     unique()
    # })

    breaks_comp1 <- shiny::reactive({
      if(input$polygon_comp1 == "Admin 2" & length(map_data_comp1()$value[which(map_data_comp1()$value == 0)]) > (length(map_data_comp1()$value)/10)){
        stats::quantile(subset(map_data_comp1()$value, map_data_comp1()$value!=0), seq(0, 1, 1 / (input$bins_comp1)), na.rm = TRUE) %>%
          unique()
      }else{
      stats::quantile(map_data_comp1()$value, seq(0, 1, 1 / (input$bins_comp1)), na.rm = TRUE) %>%
        unique()
      }
    })

    pal_new_comp1 <- shiny::reactive({
      rev(grDevices::colorRampPalette(colors = c('#2c7bb6', '#abd9e9', '#ffffbf', '#fdae61', '#d7191c'), space = "Lab")(input$bins_comp1))
    })

    pal_comp1 <- shiny::reactive ({
      leaflet::colorBin(palette = pal_new_comp1(),
                        bins= breaks_comp1(),
                        na.color = "grey",
                        domain = NULL,
                        pretty = F,
                        reverse=T)
    })

    # Pal_legend
    pal_leg_comp1 <- shiny::reactive ({
    leaflet::colorBin(
                        palette = pal_new_comp1(),
                        bins = breaks_comp1(),
                        na.color = "grey",
                        domain = map_data_comp1()[,"value"],
                        pretty = FALSE,
                        reverse=T
      )
    })


    leafproxy_comp1 <- shiny::reactive({
      leaflet::leafletProxy("double_map_1",
                            data = shps_comp1(),
                            deferUntilFlush = TRUE) %>%
        leaflet::clearShapes()
    })

    shiny::observe({
      shiny::req(map_data_comp1())

      leafproxy_comp1() %>%
        leaflet::addPolygons(
          label= labels_map_comp1(),
          labelOptions = leaflet::labelOptions(
            style = list("font-weight"= "normal",
                         padding= "3px 8px",
                         "color"= "black"),
            textsize= "10px",
            direction = "auto",
            opacity = 0.9),
          fillColor =  ~pal_comp1()(map_data_comp1()$value),
          fillOpacity = 1,
          stroke = TRUE,
          color= if(input$polygon_comp1 == "Admin 1"){"#5C4033"} else{"white"},
          weight = if(input$polygon_comp1 == "Admin 1"){1.4} else{0.8},
          opacity = 1,
          fill = TRUE,
          dashArray = c(3,3),

          smoothFactor = 1,
          highlightOptions = leaflet::highlightOptions(weight= 2.5,
                                                       color = "black",
                                                       fillOpacity = 1,
                                                       opacity= 1,
                                                       bringToFront = TRUE),
          group = "Polygons")


      # #appending darkgry for zeores

      # if(any(map_data_comp1()$value==0)){
      #   pal_new_comp1_updated <- reactive(append(pal_new_comp1(), "#5C4033"))
      # }else{
      #   pal_new_comp1_updated <- reactive(pal_leg_comp1())
      # }


      leaflet::leafletProxy("double_map_1", data= map_data_comp1()) %>%
        leaflet::clearControls() %>%
        leaflet::addLegend(
                          title = "Legend",
                          "bottomright",
                           pal= pal_leg_comp1(),   #
                           values= map_data_comp1()$value,
                           opacity= 1,
                           labFormat = leaflet::labelFormat(
                             between = " : ",
                             digits = 2))



    })

    # Message on updation of the MAPS
    shiny::observe({
      shiny::req(input$description_comp1)
      shiny::req(input$polygon_comp1)
      shiny::showNotification("New MAP is being rendered based on the selection",
                              type="message",
                              duration = 3)
    })
    # Message on updation of the Bins
    shiny::observe({
      shiny::req(input$bins_comp1)
      shiny::showNotification("Number of colorbins is being changed based on the input",
                              type="message",
                              duration = 3)
    })




    ############################################################################

    ############################################################################
    #Map2

    #Shapes
    shps_comp2 <- shiny::reactive({

      req(input$polygon_comp2)

      if(input$polygon_comp2 == "Admin 2"){
        return(nig_shp_adm2)
      }else{
        return(nig_shp_adm1)
      }

    })

    already_selected_comp2 <- shiny::reactiveVal()

    observe({
      already_selected_comp2(input$description_comp2)
    })


    shiny::observeEvent(input$polygon_comp2, {

      choices_up_comp2 = reactive({
        if(input$polygon_comp2 == "Admin 2"){
          return(indicator_listed_adm2)
        }else{
          return(indicator_listed_adm1)
        }
      })

      freezeReactiveValue(input, "description_comp2")

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "description_comp2",
        label = "Select a Variable",
        choices = choices_up_comp2(),
        selected = already_selected_comp2()
      )


    })


    #Main Map
    #selecting variable
    map_data_comp2 <- shiny::reactive({
      if(input$polygon_comp2 == "Admin 2"){
        adm2_data %>%
          dplyr::filter(description == input$description_comp2)
      }else if(input$polygon_comp2 == "Admin 1"){
        adm1_data %>%
          dplyr::filter(description == input$description_comp2)

      }
    })

    # xmin      ymin      xmax      ymax
    # 2.668534  4.273007 14.678816 13.894419
    #

    #Bounds
    # country_bounds <-   nig_shp_adm0 %>% sf::st_bbox()

    #Lealfet static options
    output$double_map_2 <- leaflet::renderLeaflet({
      leaflet::leaflet(options = leaflet::leafletOptions(zoomSnap = 0.20, zoomDelta = 0.20)) %>%
        leaflet::addProviderTiles(provider =  "CartoDB.Voyager") %>%
        # leaflet::fitBounds(country_bounds[[1]], country_bounds[[2]], country_bounds[[3]], country_bounds[[4]]) %>%
        leaflet::setView(lng=11, lat = 13, zoom = 5) %>%
        leaflet.minicharts::syncWith("combined_map")
    })

    #To render leafelt map before proxy observer updates
    outputOptions(output, "double_map_2", suspendWhenHidden = FALSE)


    #Labelling for the Map
    labels_map_comp2 <- shiny::reactive({
      paste0(glue::glue("<b>Admin: { shps_comp2()$ADM_NAME } </b> </br>"),
             glue::glue("<b>Variable:</b> { map_data_comp2()$description }</br>"),
             glue::glue("<b>Value: <b/>  { round(map_data_comp2()$value, 3) }"),
             sep = "") %>%
        lapply(htmltools::HTML)
    })

    #breaks defined
    # breaks_comp2 <- shiny::reactive({
    #   stats::quantile(map_data_comp2()$value, seq(0, 1, 1 / (input$bins_comp2)), na.rm = TRUE) %>%
    #     unique()
    # })
    breaks_comp2 <- shiny::reactive({
      if(input$polygon_comp2 == "Admin 2" & length(map_data_comp2()$value[which(map_data_comp2()$value == 0)]) > (length(map_data_comp2()$value)/10)){
        stats::quantile(subset(map_data_comp2()$value, map_data_comp2()$value!=0), seq(0, 1, 1 / (input$bins_comp2)), na.rm = TRUE) %>%
          unique()
      }else{
        stats::quantile(map_data_comp2()$value, seq(0, 1, 1 / (input$bins_comp2)), na.rm = TRUE) %>%
          unique()
      }
    })

    pal_new_comp2 <- shiny::reactive({
      rev(grDevices::colorRampPalette(colors = c('#2c7bb6', '#abd9e9', '#ffffbf', '#fdae61', '#d7191c'), space = "Lab")(input$bins_comp2))
    })

    pal_comp2 <- shiny::reactive ({
      leaflet::colorBin(palette = pal_new_comp2(),
                        bins= breaks_comp2(),
                        na.color = "grey",
                        domain = NULL,
                        pretty = F,
                        reverse=T)
    })

    # Pal_legend
    pal_leg_comp2 <- shiny::reactive ({
      leaflet::colorBin(palette = pal_new_comp2(),
                        bins = breaks_comp2(),
                        na.color = "grey",
                        domain = map_data_comp2()[,"value"],
                        pretty = FALSE,
                        reverse=T
      )
    })


    leafproxy_comp2 <- shiny::reactive({
      leaflet::leafletProxy("double_map_2",
                            data = shps_comp2(),
                            deferUntilFlush = TRUE) %>%
        leaflet::clearShapes()
    })

    shiny::observe({
      shiny::req(map_data_comp2())

      leafproxy_comp2() %>%
        leaflet::addPolygons(
          label= labels_map_comp2(),
          labelOptions = leaflet::labelOptions(
            style = list("font-weight"= "normal",
                         padding= "3px 8px",
                         "color"= "black"),
            textsize= "10px",
            direction = "auto",
            opacity = 0.9),
          fillColor =  ~pal_comp2()(map_data_comp2()$value),
          fillOpacity = 1,
          stroke = TRUE,
          color= if(input$polygon_comp2 == "Admin 1"){"#5C4033"} else{"white"},
          weight = if(input$polygon_comp2 == "Admin 1"){1.4} else{0.8},
          opacity = 1,
          fill = TRUE,
          dashArray = c(3,3),

          smoothFactor = 1,
          highlightOptions = leaflet::highlightOptions(weight= 2.5,
                                                       color = "black",
                                                       fillOpacity = 1,
                                                       opacity= 1,
                                                       bringToFront = TRUE),
          group = "Polygons")


      leaflet::leafletProxy("double_map_2", data= map_data_comp2()) %>%
        leaflet::clearControls() %>%
        leaflet::addLegend(
                          title = "Legend",
                          "bottomright",
                           pal= pal_leg_comp2(),
                           values= map_data_comp2()$value,
                           opacity= 1,
                           labFormat = leaflet::labelFormat(
                             between = " : ",
                             digits = 2))

    })

    # Message on updation of the MAPS
    shiny::observe({
      shiny::req(input$description_comp2)
      shiny::req(input$polygon_comp2)
      shiny::showNotification("New MAP is being rendered based on the selection",
                              type="message",
                              duration = 3)
    })
    # Message on updation of the Bins
    shiny::observe({
      shiny::req(input$bins_comp2)
      shiny::showNotification("Number of colorbins is being changed based on the input",
                              type="message",
                              duration = 3)
    })

    ############################################################################

  })
}

## To be copied in the UI
# mod_comp_maps_ui("comp_maps_1")

## To be copied in the server
# mod_comp_maps_server("comp_maps_1")
