###############################################################################
# Act-Like-Me.org
#
# Author: Garvin Kruthof
###############################################################################

ui = shiny::htmlTemplate(
  # Index Page
  "www/index.html",
  
 
  # User Input

social_distancing= sliderInput("social_distancing", "",min = 0, max = 100, value = 50,width = "100%"),
wash_hand= sliderInput("wash_hand", "",min = 0, max = 100, value = 50,width = "100%"),

evolution = plotOutput('act_immune_people'),
healthsystem = plotOutput('hospital'),


  

  
  # Leaflet 
  leaflet_map = leafletOutput(outputId = "map") %>% 
    withSpinner(color="#0dc5c1")
)