###############################################################################
# Act-Like-Me.org
#
# Author: Garvin Kruthof
###############################################################################

ui = shiny::htmlTemplate(
  # Index Page
  "www/index.html",
  
 
  # User Input

no_contacts= sliderInput("no_contacts", "",min = 0, max = 40, value = 20,width = "100%"),
wash_hand= sliderInput("wash_hand", "",min = 0, max = 10, value = 1,width = "100%"),
public_transport= sliderInput("public_transport", "",min = 0, max = 10, value = 1,width = "100%"),

evolution = plotOutput('act_immune_people'),
healthsystem = plotOutput('hospital'),
start_sim = actionButton("start_sim", "Start Simulator!"),
#hospitaltext = textOutput("hospital_test"),
text_intro=textOutput("text_intro"),
text_repeat=textOutput("text_repeat"),


  

  
  # Leaflet 
  leaflet_map = leafletOutput(outputId = "map") %>% 
    withSpinner(color="#0dc5c1")
)