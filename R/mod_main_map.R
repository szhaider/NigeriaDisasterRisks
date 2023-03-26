#' main_map UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
#' @importFrom shiny selectInput tags verbatimTextOutput absolutePanel req observe observeEvent reactive
#' @importFrom leaflet leaflet leafletOutput renderLeaflet addProviderTiles setView
#' @importFrom leaflet leafletOptions addPolygons labelOptions highlightOptions
#' @importFrom  leaflet tileOptions leafletProxy addLegend clearControls clearShapes
#' @importFrom htmltools HTML tags
#' @importFrom glue glue
#' @importFrom dplyr filter mutate slice_max
#' @importFrom forcats fct_reorder
#' @import shiny
#' @importFrom shinyWidgets pickerInput updatePickerInput
#' @importFrom shinyscreenshot screenshot
#' @importFrom  ggplot2 ggplot geom_col aes labs theme element_line element_blank
#'
mod_main_map_ui <- function(id){
  ns <- NS(id)
  tagList(
    tagList(
      sidebarLayout(
                 sidebarPanel(
                   width = 4,
                   style = "background-color: white;
                            margin-top: -20px;
                            margin-bottom:0px;",
                   # tags$strong(tags$em(tags$h6("Select the variables using the dropdown menu below for the maps"))),
                  # shiny::selectInput(ns("description"),
                  #                      "Select a Variable: ",
                  #                      choices = indicator_listed_adm2),

                  # shinyWidgets::pickerInput(
                  #
                  #     inputId = ns("description"),
                  #     label = "Select a Variable: ",
                  #     choices = indicator_listed_adm2,
                  #     options = list(`live-search` = TRUE),
                  #     choicesOpt = list(
                  #       style = rep_len("font-size: 90%; line-height: 1.6;", 30)
                  #     )
                  #     ),
                  #
                  #
                  #
                  #
                  # shiny::numericInput(ns("bins"),
                  #                     label = "Choose number of Bins",
                  #                     min = 3,
                  #                     max= 13,
                  #                     value = 5,
                  #                     step=1),
                  h5(tags$b(tags$em("Click on the map polygons to access the ranked variation within Admin 2"))),

                  shiny::plotOutput(ns("district_bars"),
                                    height = "500px",
                                    width = '100%'),
                  # br(),



                   # downloadButton(ns("mapdata"), "Data", class= "btn-sm"),
                   # actionButton(ns("screenshot"), "Image",class="btn-sm", icon=icon("camera")),
                   # actionButton(ns("help_map"), "Help", icon= icon('question-circle'), class ="btn-sm"),
                   # br(),

     ),
     shiny::mainPanel(
       width = 8,


      tags$style(type = "text/css", "#main_map_1-main_map {height: calc(103vh - 100px) !important;
                       position: relative;
                       margin-left: -25px;
                       margin-right: -25px;
                       margin-top: 0px;
                       margin-bottom: -40px;
                       padding: 0px;
                  }"),
       leaflet::leafletOutput(ns("main_map"),
                              # height = '100vh',
                              width = "68vw"),


      shiny::absolutePanel(
         id = "controls", class = "panel panel-default", fixed= TRUE,
         draggable = FALSE, bottom = "auto", left = "auto", right = 5, top = 60,
         width = 300, height = "auto",
         # style = "background-color: white;
         #           opacity: 0.9;
         #           padding: 5px 5px 5px 5px;
         #           margin: auto;
         #           border-radius: 5pt;
         #           box-shadow: 0pt 0pt 0pt 0px rgba(61,59,61,0.48);
         #           padding-bottom: 0.5mm;
         #           padding-top: 1mm;",

         shinyWidgets::pickerInput(
           inputId = ns("description"),
           label = "Select a Variable: ",
           choices = indicator_listed_adm1,

           options = list(`live-search` = TRUE,
                           `dropdown-align-right` = 'auto',
                          style =  "my-pickerinput" ),
           choicesOpt = list(

             style = rep_len("font-size: 90%; line-height: 1.6;", 30))
         ),

         # shiny::numericInput(ns("bins"),
         #                     label = "Choose number of Bins",
         #                     min = 3,
         #                     max= 13,
         #                     value = 5,
         #                     step=1),

         shinyWidgets::pickerInput(
           inputId = ns("polygon"),
           label = "Select Admin level: ",
           choices = c("Admin 1", "Admin 2"),
          options = list(`dropdown-align-right` = 'auto',
                         style =  "my-pickerinput" ),
           choicesOpt = list(style = rep_len("font-size: 90%; line-height: 1.6;", 30))
         ),

         shiny::sliderInput(ns("bins"),
                            label = "Choose number of Bins",
                            min = 3,
                            max= 13,
                            value = 5,
                            step=1),
         ),
       # shiny::verbatimTextOutput(ns("source_main_map")),
       # tags$head(tags$style("#main_maps_1-source_main_map {color:black; font-size:12px; font-style:italic;
       #               max-height: 120px; background: #ffe6cc;}"))

     )
     )
    )
  )
}

#' main_map Server Functions
#'
#' @noRd
mod_main_map_server <- function(id){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    #Shapes
    shps <- shiny::reactive({

      req(input$polygon)

      if(input$polygon == "Admin 2"){
        return(nig_shp_adm2)
      }else{
        return(nig_shp_adm1)
      }

    })

    #Select options based on admin level since all vars in both admins aren't available

    #Already selcted to stop reverting to the first var when admin shifts
    already_selected <- shiny::reactiveVal()

    observe({
      already_selected(input$description)
    })


    shiny::observeEvent(input$polygon, {

      choices_up = reactive({
        if(input$polygon == "Admin 2"){
          return(indicator_listed_adm2)
        }else{
          return(indicator_listed_adm1)
        }
      })

      freezeReactiveValue(input, "description")  #to stop the logic from breaking by flickering of irrelevant output

      shinyWidgets::updatePickerInput(
        session = session,
        inputId = "description",
        label = "Select a Variable",
        choices = choices_up(),
        selected = already_selected()
        # ,
        # selected = input$description
        #Use this to stop resetiing select options, but need to have same vars in both admins data files, otherwise logic breaks
        #Insteaead let it reset
      )


    })


    #Main Map
    #selecting variable
    map_data <- shiny::reactive({
      # req(input$polygon)
      if(input$polygon == "Admin 2"){
        adm2_data %>%
          dplyr::filter(description == input$description)
      }else if(input$polygon == "Admin 1"){
        adm1_data %>%
          dplyr::filter(description == input$description)
      # }else if(is.na(input$description)){
      #   adm1_data %>%
      #     dplyr::filter(description == input$description)
       }
    })


#Bounds
  country_bounds <-   nig_shp_adm0 %>% sf::st_bbox()

    #Lealfet static options
 output$main_map <- leaflet::renderLeaflet({
      # message("rendering local map")
      leaflet::leaflet(options = leaflet::leafletOptions(zoomSnap = 0.20, zoomDelta = 0.20)) %>%
        leaflet::addProviderTiles(provider =  "CartoDB.Voyager") %>%
     leaflet::fitBounds(country_bounds[[1]], country_bounds[[2]], country_bounds[[3]], country_bounds[[4]]) %>%
     leaflet::setView(lng=10, lat = 9, zoom = 4.8) #
    })

 #Need to check
 outputOptions(output, "main_map", suspendWhenHidden = FALSE, priority = 1000)

    # map_data <- reactive({
    #     if(input$polygon == "Admin 2"){
    #     adm2_data %>%
    #       dplyr::filter(description == input$description)
    #     }else{
    #       adm2_data %>%
    #       dplyr::filter(description == input$description) %>%
    #       dplyr::group_by(ADM2_NAME) %>%
    #       dplyr::summarise(value= mean(value))
    #       }
    # })



    #Labelling for the Map
    labels_map <- shiny::reactive({
      paste0(glue::glue("<b>Admin: { shps()$ADM_NAME } </b> </br>"),
             # glue::glue("<b>Variable: { map_data()$description } </b>"), " ",
             glue::glue("<b>Value: <b/>  { round(map_data()$value, 3) }"),
             sep = "") %>%
        lapply(htmltools::HTML)
    })

    #Color Scheme
    # pal_new <- reactive({
    #   req(unique(map_data()$context) %in% c("negative", "positive"))
    #   if (unique(map_data()$context) == "negative"){
    #     rev(grDevices::colorRampPalette(colors = c('#2c7bb6', '#abd9e9', '#ffffbf', '#fdae61', '#d7191c'), space = "Lab")(input$bins))
    #   } else {
    #     grDevices::colorRampPalette(colors = c('#2c7bb6', '#abd9e9', '#ffffbf', '#fdae61', '#d7191c'), space = "Lab")(input$bins)
    #   }
    # })

    #breaks defined
    breaks <- shiny::reactive({
      # req(unique(map_data()$context) %in% c("negative", "positive"))
      stats::quantile(map_data()$value, seq(0, 1, 1 / (input$bins)), na.rm = TRUE) %>%
        unique()
    })

    pal_new <- shiny::reactive({
      rev(grDevices::colorRampPalette(colors = c('#2c7bb6', '#abd9e9', '#ffffbf', '#fdae61', '#d7191c'), space = "Lab")(input$bins))
    })

    pal <- shiny::reactive ({
      leaflet::colorBin(palette = pal_new(),
                        bins= breaks(),
                        na.color = "grey",
                        domain = NULL,
                        pretty = F,
                        reverse=T)
    })

    # Pal_legend
    pal_leg <- shiny::reactive ({
      leaflet::colorBin(palette = pal_new(),
                        bins= breaks(),
                        na.color = "grey",
                        domain = map_data()[,"value"],
                        pretty = FALSE,
                        reverse=T
      )
    })

    #Dynamic leaflet
     # shiny::observeEvent(input$polygon,{

  # shiny::observe({

  # req(input$polygon)

   leafproxy <- shiny::reactive({

       # req(input$polygon)

       leaflet::leafletProxy("main_map",
                             data = shps(),
                             deferUntilFlush = TRUE) %>%
           leaflet::clearShapes()
   })

     # })



  shiny::observe({
    # shiny::observe({
    #
    shiny::req(map_data())

    # leafproxy() %>%
    # leaflet::leafletProxy("main_map",
    #                       data = shps(),
    #                       deferUntilFlush = TRUE) %>%
    #   leaflet::clearShapes() %>%
    leafproxy() %>%
        leaflet::addPolygons(
          layerId = ~ADM1_CODE,   #To make interactive plots based on polygons
          label= labels_map(),
                             labelOptions = leaflet::labelOptions(
                               style = list("font-weight"= "normal",
                                            padding= "3px 8px",
                                            "color"= "black"),
                               textsize= "10px",
                               direction = "auto",
                               opacity = 0.9),
                             fillColor =  ~pal()(map_data()$value),
                             fillOpacity = 1,
                             stroke = TRUE,
                             color= "white",
                             weight = 1,
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


      leaflet::leafletProxy("main_map", data= map_data()) %>%
        leaflet::clearControls() %>%
        leaflet::addLegend("bottomleft",
                           pal= pal_leg(),
                           values= map_data()$value,
                           # title =
                           #   if(unique(map_data()$units)!=""){
                           #     paste0("Indicator", " ","(", unique(map_data()$units), ")")
                           #   }else{
                           #     "Indicator"
                           #   },
                           opacity= 1,
                           labFormat = leaflet::labelFormat(
                             between = " : ",
                             digits = 2))

    })





    # Message on updation of the MAPS
    shiny::observe({
      shiny::req(input$description)
      shiny::req(input$polygon)
      shiny::showNotification("New MAP is being rendered based on the selection",
                              type="message",
                              duration = 3)
    })
    # Message on updation of the Bins
    shiny::observe({
      shiny::req(input$bins)
      shiny::showNotification("Number of colorbins is being changed based on the input",
                              type="message",
                              duration = 3)
    })


    #Source of the slected indicator
    # output$source_main_map <- shiny::renderText({
    #   paste(" Source: ", glue("{ unique(map_data()$description) }"),
    #         "\n",
    #         "Definition: ", glue("{ unique(map_data()$description) }"))
    # })

    #Screenshot
    shiny::observeEvent(input$screenshot,{
      shinyscreenshot::screenshot(filename = glue::glue("{ input$variable }"),
                                  id = "main_map", scale = 0.90, timer = 1)
    })

    #Download data underlying the shown map
    output$mapdata <- shiny::downloadHandler(
      filename = function(){
        paste(glue::glue("{ input$variable }"), ".csv")
      },
      content = function(file){
        write.csv(map_data(), file)
      }
    )

    #Main Interactive Maps
    ##############################################.
    #### Modal  ----
    ###############################################.
    shiny::observeEvent(input$help_map, {
      shiny::showModal(modalDialog(
        title = "How to use these maps",
        p("These maps give Admin 2 level estimates of various geo-spatial indicators"),
        p("All indicators are rounded to 2 decimal points"),
        # p("All Natural Hazards Indicators are rounded to 3 decimal points"),
        # p("Expect the color mapping to reverse with the context of  the selected indicators - e.g. Poverty (High) = Red whereas; Access to improved toilet facilities (High) = Blue"),
        size = "m", easyClose = TRUE, fade=FALSE,footer = modalButton("Close (Esc)")))
    })

    #Main District Bars
    ##############################################.
    ####Bar Chart  ---- May be go for top 10
    ###############################################

    observe({

      event <- input$main_map_shape_click

       tehsil <- nig_shp_adm1$ADM_NAME[ nig_shp_adm1$ADM1_CODE == event$id]

       chart_data <-
             # req(input$polygon == "Admin 1")
             adm2_data %>%
               filter(description == input$description) %>%
               filter(ADM1_NAME %in% tehsil) %>%
               mutate(ADM2_NAME = fct_reorder(factor(ADM2_NAME), value, .na_rm=FALSE))


       output$district_bars <- renderPlot({
           chart_data %>%
             ggplot(aes(y= ADM2_NAME,
                        x=value)) +
             geom_col(fill="seagreen",
                       width = 0.6,
                       alpha=0.7) +
             labs(y= "Admin 2",
                  x = "Variable")+
             theme(
               axis.line = element_line(color='black'),
               plot.background = element_blank(),
               panel.grid.major = element_blank(),
               panel.grid.minor = element_blank(),
               panel.border = element_blank())
             })

         # output$source_main_map <- shiny::renderText({
         #   if(is.null(tehsils)){
         #     print("dvbdshvbsd")
         #   }else{
         #     print(tehsils)
         #   }
         #   })
         # shiny::renderText(nig_shp_adm1$ADM_NAME[nig_shp_adm1$ADM1_CODE == click_event$id])

    })

    # observe({
    #
    #   click_event <- input$map_shape_click
    #
    #   tehsil <- nig_admins$adm1$ADM_NAME[nig_admins$adm1$ADM1_CODE == click_event$id]
    #
    #
    #   chart_data <-
    #     # req(input$polygon == "Admin 1")
    #     adm2_data %>%
    #       filter(description == input$description) %>%
    #       mutate(ADM2_NAME = fct_reorder(factor(ADM2_NAME), value, .na_rm=FALSE)) %>%
    #       filter(ADM1_NAME %in% c(tehsil))
    #
    #   output$district_bars <- renderPlot({
    #   chart_data %>%
    #     ggplot(aes(y= ADM2_NAME,
    #                x=value)) +
    #     geom_col(fill="seagreen",
    #               width = 0.6,
    #               alpha=0.7) +
    #     labs(y= "Admin 2",
    #          x = "Variable")+
    #     theme(
    #       axis.line = element_line(color='black'),
    #       plot.background = element_blank(),
    #       panel.grid.major = element_blank(),
    #       panel.grid.minor = element_blank(),
    #       panel.border = element_blank())
    #     })
    # })






  })
}

## To be copied in the UI
# mod_main_map_ui("main_map_1")

## To be copied in the server
# mod_main_map_server("main_map_1")
