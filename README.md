
<!-- README.md is generated from README.Rmd. Please edit that file -->

# NigeriaDisasterRisks

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

The goal of NigeriaDisasterRisks application is to visualize findings
from Nigeria disaster risks layers from various geo-spatial data sources

## Installation

You can install the development version of NigeriaDisasterRisks like so:

``` r
# To install the Nigeria application 

remotes::install_github("szhaider/NigeriaDisasterRisks")

# To launch the app locally
library(NigeriaDisasterRisks)
NigeriaDisasterRisks::run_app()

#To run directly from Github
library(shiny)
shiny::runGitHub("NigeriaDisasterRisks", "szhaider")
```

These are some basic details about the data used in the application:

## Various Disaster Risks dimensions covered

    #>  [1] "Total population (#) according to WorldPop 2020 - UN adjusted, constrained to builtup"                                             
    #>  [2] "Relative Wealth Index"                                                                                                             
    #>  [3] "Total population according to provided census at LGA level"                                                                        
    #>  [4] "Total area of builtup (hectares) according to World Settlement Footprint 2019"                                                     
    #>  [5] "Total area of agricultural land (hectares) according to ESA land cover 2020"                                                       
    #>  [6] "Expected mortality from river floods (population count)"                                                                           
    #>  [7] "Expected mortality from river floods (% of ADM3 population)"                                                                       
    #>  [8] "Expected damage on builtup from river floods (hectars)"                                                                            
    #>  [9] "Expected damage on builtup from river floods (% of ADM3 builtup)"                                                                  
    #> [10] "Expected damage on agricultural land from river floods (hectars)"                                                                  
    #> [11] "Expected damage on agricultural land from river floods (% of ADM3 builtup)"                                                        
    #> [12] "Expected mortality from coastal floods (population count)"                                                                         
    #> [13] "Expected mortality from coastal floods (% of ADM3 population)"                                                                     
    #> [14] "Expected damage on builtup from coastal floods (hectars)"                                                                          
    #> [15] "Expected damage on builtup from coastal floods (% of ADM3 builtup)"                                                                
    #> [16] "Expected damage on agricultural land from coastal floods (hectars)"                                                                
    #> [17] "Expected damage on agricultural land from coastal floods (% of ADM3 builtup)"                                                      
    #> [18] "Expected mortality from river and coastal floods (population count)"                                                               
    #> [19] "Expected damage on builtup from river and coastal floods (hectars)"                                                                
    #> [20] "Expected damage on agricultural land from river and coastal floods (hectars)"                                                      
    #> [21] "Population exposed to medium or high hazard (population count)"                                                                    
    #> [22] "Population exposed to medium or high hazard (% of ADM2 population)"                                                                
    #> [23] "Builtup exposed to medium or high hazard (Builtup count)"                                                                          
    #> [24] "Builtup exposed to medium or high hazard (% of ADM2 Builtup)"                                                                      
    #> [25] "Frequency of agricultural stress affecting at least 30% of arable land during Season 1 (percentage of historical period 1984-2022)"
    #> [26] "Frequency of agricultural stress affecting at least 30% of arable land during Season 2 (percentage of historical period 1984-2022)"
    #> [27] "Expected impact from heat stress (population count)"                                                                               
    #> [28] "Expected impact from heat stress (% of ADM3 population)"                                                                           
    #> [29] "Expected increse of mortality from air pollution (population count)"                                                               
    #> [30] "Expected increse of mortality from air pollution (% of ADM3 population)"

## Admin 1 for Nigeria

    #>  [1] "Abia"        "Adamawa"     "Akwa Ibom"   "Anambra"     "Bauchi"     
    #>  [6] "Bayelsa"     "Benue"       "Borno"       "Cross River" "Delta"      
    #> [11] "Ebonyi"      "Edo"         "Ekiti"       "Enugu"       "Abuja"      
    #> [16] "Gombe"       "Imo"         "Jigawa"      "Kaduna"      "Kano"       
    #> [21] "Katsina"     "Kebbi"       "Kogi"        "Kwara"       "Lagos"      
    #> [26] "Nassarawa"   "Niger"       "Ogun"        "Ondo"        "Osun"       
    #> [31] "Oyo"         "Plateau"     "Rivers"      "Sokoto"      "Taraba"     
    #> [36] "Yobe"        "Zamfara"     "Lake"
