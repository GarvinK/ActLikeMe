fluidPage(
  
  titlePanel("Conditional panels"),
  
  column(4, wellPanel(
    sliderInput("n", "Number of points:",
                min = 10, max = 200, value = 50, step = 10)
  )),
  
  column(5,
         "The plot below will be not displayed when the slider value",
         "is less than 50.",
         
         # With the conditionalPanel, the condition is a JavaScript
         # expression. In these expressions, input values like
         # input$n are accessed with dots, as in input.n
         conditionalPanel("input.n >= 50",
                          plotOutput("scatterPlot", height = 300)
         ),
         conditionalPanel("About You", value = "simulator",
                          br(),
                          sliderInput("avg_relationships_per_person", "Wie gross ist Dein Bekanntenkreis?:",
                                      min = 0, max = 30, value = 5
                          ),
                          actionButton("start_sim", "Zeig mir mein Footprint")
         ),
         conditionalPanel(
           condition = "input.selected_tab == 'simulator'",
           h2("Dein Covid-19 Footprint"),
           
           #h3(textOutput('dataset_tweets_sorted_by')),
           plotOutput('act_immune_people')
           
         )
         
  )
)