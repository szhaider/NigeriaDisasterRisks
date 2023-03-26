# Launch the ShinyApp (Do not remove this comment)
# To deploy, run:rsconnect::deployApp(account= ,server= )
#
# Or use the blue button on top of this file

# library(sf)

pkgload::load_all(export_all = FALSE, helpers = FALSE, attach_testthat = FALSE)
options( "golem.app.prod" = TRUE)
NigeriaDisasterRisks::run_app() # add parameters here (if any)

#Deploy App
 # rsconnect::deployApp(account ="shaider7")
# rsconnect::deployApp(account ="")
