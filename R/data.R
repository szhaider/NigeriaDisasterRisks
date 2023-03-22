# library(dplyr)

#Main dataset load for the app
data("my_dataset")
#Admin1 Data preped
adm1_data <- my_dataset$adm1_data

#Admin 2 data prepped
adm2_data <- my_dataset$adm2_data

#Admins Boundaries load for the app
data("nig_admins")

nig_shp_adm0 <- sf::st_as_sf(nig_admins$adm0)

nig_shp_adm1 <- sf::st_as_sf(nig_admins$adm1)

nig_shp_adm2 <- sf::st_as_sf(nig_admins$adm2)

#List of variables
#Listed Indicator Options

#admin 1
indicator_listed_adm1 = (list(
  `Relative Wealth Index` = list('Relative Wealth Index'),
  `Demography` = list("Total population according to provided census at LGA level",
                      "Total population (#) according to WorldPop 2020 - UN adjusted, constrained to builtup"),
  `Population Exposure` = list("Population exposed to medium or high hazard (population count)"),
  `Builtup Exposure` = list("Builtup exposed to medium or high hazard (Builtup count)"),
  `Agriculture Area`  = list("Total area of agricultural land (hectares) according to ESA land cover 2020"),
  `Built-up Area` = list("Total area of builtup (hectares) according to World Settlement Footprint 2019"),
  # `River flooding` = list("Expected mortality from river floods (population count)",
  #                         "Expected mortality from river floods (% of ADM3 population)",
  #                         "Expected damage on builtup from river floods (hectars)",
  #                         "Expected damage on builtup from river floods (% of ADM3 builtup)",
  #                         "Expected damage on agricultural land from river floods (hectars)",
                          # "Expected damage on agricultural land from river floods (% of ADM3 builtup)"),
  `River flooding & Coastal flooding` = list("Expected mortality from river and coastal floods (population count)",
                                             "Expected mortality from river and coastal floods (% of ADM1 builtup)",
                                             "Expected damage on builtup from river and coastal floods (hectars)",
                                             "Expected damage on builtup from river and coastal floods  (% of ADM1 builtup)",
                                             "Expected damage on agricultural land from river and coastal floods (hectars)",
                                             "Expected damage on agricultural land from river and coastal floods  (% of ADM1 builtup)"),
  `Heat stress` = list("Expected impact from heat stress (population count)",
                       "Expected impact from heat stress (% of ADM1 population)"),
  `Air pollution`= list("Expected increse of mortality from air pollution (% of ADM1 population)",
                        "Expected increse of mortality from air pollution (population count)"),
  `Agricultural Stress` = list("Frequency of agricultural stress affecting at least 30% of arable land during Season 1 (percentage of historical period 1984-2022)",
                               "Frequency of agricultural stress affecting at least 30% of arable land during Season 2 (percentage of historical period 1984-2022)")

))


#admin 2
indicator_listed_adm2 = (list(
                        `Relative Wealth Index` = list('Relative Wealth Index'),
                        `Demography` = list("Total population according to provided census at LGA level",
                                            "Total population (#) according to WorldPop 2020 - UN adjusted, constrained to builtup"),
                        `Population Exposure` = list("Population exposed to medium or high hazard (population count)",
                                                     "Population exposed to medium or high hazard (% of ADM2 population)"),
                        `Builtup Exposure` = list("Builtup exposed to medium or high hazard (Builtup count)",
                                                  "Builtup exposed to medium or high hazard (% of ADM2 Builtup)"),
                        `Agriculture Area`  = list("Total area of agricultural land (hectares) according to ESA land cover 2020"),
                        `Built-up Area` = list("Total area of builtup (hectares) according to World Settlement Footprint 2019"),
                        `River flooding` = list("Expected mortality from river floods (population count)",
                                                 "Expected mortality from river floods (% of ADM2 population)",
                                                 "Expected damage on builtup from river floods (hectars)",
                                                 "Expected damage on builtup from river floods (% of ADM2 builtup)",
                                                 "Expected damage on agricultural land from river floods (hectars)",
                                                 "Expected damage on agricultural land from river floods (% of ADM2 builtup)"),
                        `River flooding & Coastal flooding` = list("Expected mortality from river and coastal floods (population count)",
                                                                   "Expected damage on builtup from river and coastal floods (hectars)",
                                                                   "Expected damage on agricultural land from river and coastal floods (hectars)"),
                        `Heat stress` = list("Expected impact from heat stress (population count)",
                                             "Expected impact from heat stress (% of ADM2 population)"),
                        `Air pollution`= list("Expected increse of mortality from air pollution (% of ADM2 population)",
                                              "Expected increse of mortality from air pollution (population count)"),
                         `Coastal flooding` = list("Expected mortality from coastal floods (population count)",
                                                   "Expected mortality from coastal floods (% of ADM2 population)",
                                                   "Expected damage on builtup from coastal floods (hectars)",
                                                   "Expected damage on builtup from coastal floods (% of ADM2 builtup)",
                                                   "Expected damage on agricultural land from coastal floods (hectars)",
                                                   "Expected damage on agricultural land from coastal floods (% of ADM2 builtup)"),
                         `Agricultural Stress` = list("Frequency of agricultural stress affecting at least 30% of arable land during Season 1 (percentage of historical period 1984-2022)",
                                                      "Frequency of agricultural stress affecting at least 30% of arable land during Season 2 (percentage of historical period 1984-2022)")

                         ))
