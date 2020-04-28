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
public_transport= radioButtons("public_transport", label = h3(""),
                               choices = list("Yes" = 1, "No" = 2), 
                               selected = 2),

mask= radioButtons("mask", label = h3(""),
                               choices = list("Yes" = 1, "No" = 2), 
                               selected = 2),
social_distancing= sliderInput("social_distancing", "",min = 0, max = 10, value = 5,width = "100%"),
evolution = plotOutput('act_immune_people'),
advice_text = textOutput('text_advice'),
healthsystem = plotOutput('hospital'),
start_sim = actionButton("start_sim", "Start Simulator!"),
hospitaltext = textOutput("hospital_test"),
text_intro=textOutput("text_intro"),
text_repeat=textOutput("text_repeat"),


  

  
  # Leaflet 
  leaflet_map = leafletOutput(outputId = "map") %>% 
    withSpinner(color="#0dc5c1")
)