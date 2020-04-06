library(shiny)
library(dplyr)
library(purrr)
library(readr)
library(stringr)
library(magrittr)
library(RNetLogo)
library(ggplot2)


ui <- fluidPage(
  tags$head(HTML('<link href="https://fonts.googleapis.com/css?family=Roboto+Mono" rel="stylesheet">')),
  tags$head(HTML('<style>* {font-size: 100%; font-family: Roboto Mono;}</style>')),
  tags$head(HTML('<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>')),
  fluidRow(
    column(1),
    
    
    column(8,
           h2("Act-Like-Me"),
           HTML("Das öffentliche Leben in der Schweiz steht seit Wochen still. Du weisst zwar, dass die Lage ernst ist, doch langsam wirst du ungeduldig. Tragen deine persönlichen Einschränkungen wirklich zur Überwindung der Krise bei? Wir zeigen dir die direkten Auswirkungen deiner täglichen Entscheidungen auf. Wie würde sich die Corona-Krise entwickeln, wenn alle so handelten wie du?")
           ,
           
           br(),
           br(),
           br(),
           # sliderInput("probability_of_contac3", "Anzahl private physische Kontakte der letzten 7 Tage:",
           #             min = 0, max = 20, value = 5,width = "100%"
           # ),
           # sliderInput("probability_of_contact1", "Anzahl berufliche Kontakte der letzten 7 Tage:",
           #             min = 0, max = 40, value = 20,width = "100%"
           # ),
           # 
           # 
           # radioButtons("dist", "Wie viel Kontakt zu Risikogruppen hattest?",
           #              c("Keinen" = "norm",
           #                "Weniger als 3" = "unif",
           #                "Mehr als 3" = "lnorm")),
           sliderInput("probability_of_contact", "Wie gut hälst Du Dich an BAG - Richtlinien?",
                       min = 0, max = 100, value = 50,width = "100%"
           ),
           
           actionButton("start_sim", "Was hätte mein Verhalten für Auswirkungen?"),
           
           br(),
           br(),
           br(),
           br(),
           tabsetPanel(id = "selected_tab", type = "tabs", selected = "simulator",
                       tabPanel("Infektionsraten", value = "simulator",
                                br()
                                
                       ),
                       
                       tabPanel("Auswirkungen auf das Gesundheitsystem", value = "dataset",
                                br()
                                
                                
                                
                                
                       )
           )
           ,
           conditionalPanel(
             condition = "input.selected_tab == 'simulator'",
             h2("So würde der Pandemie-Verlauf aussehen, wenn alle so handeln würden wie Du:"),
             #h3(textOutput('dataset_tweets_sorted_by')),
             plotOutput('act_immune_people')
             
           ),
           conditionalPanel(
             condition = "input.selected_tab == 'dataset'",
             h2("So würde das Gesundheitssystem aussehen, wenn alle so handeln würden wie Du:"),
             plotOutput('hospital')
           ),
           img(src='https://github.githubassets.com/images/modules/open_graph/github-mark.png', width="10%", height="10%", align = "centre"),
           HTML("<a href='https://github.com/GarvinK/ActLikeMe'>Source Code on GitHub</a> "),
           br(),
           br()
    ),
    column(1)
  )
)


server <- function(input, output, session) {
  
  v <- reactiveValues(data = NULL)
  
  nl.path <- "/home/garvin_kruthof/netlogo/app"
  nl.jarname <- "netlogo-6.0.4.jar"
  NLStart(nl.path, nl.jarname=nl.jarname,gui=FALSE)
  model.path <- "/srv/shiny-server/Covid19/model/prototype_simple.nlogo"
  NLLoadModel(model.path)
  
  observeEvent(input$start_sim, {
    NLCommand(paste('set probability-of-contact ',toString(100-input$probability_of_contact),sep=""))
    
    NLCommand("setup")
    #NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    NLCommand("setup-experiment")
    #NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    #v <- NLDoReport(10, "go", "act-immune-people")
    v <- NLDoReport(100, "go", c("act-immune-people","act-dead-people","act-infect-people","act-hosp-people","act-required-hosp"),
                    as.data.frame=TRUE, df.col.names=c("act_immune_people","act_dead_people","act_infect_people","act_hosp_people","act_required_hosp "))
    
    output$act_immune_people <- renderPlot({
      #if (is.null(v$data)) return()
      #plot(v$act_immune_people)
      ggplot(v, aes(x=seq(1:100))) + 
        coord_cartesian(xlim = c(0, 100), ylim = c(0, 1))+
        geom_line(aes(y=act_immune_people, col="Immunität in der Bevölkerung"),lwd=2.5)+ 
        geom_line(aes(y=act_infect_people, col="Infektionen"),lwd=2.5)+
        geom_line(aes(y=act_dead_people, col="Todesfälle"),lwd=2.5)+
        
        labs(y = "Anzahl der Bevölkerung in Prozent")+
        labs(x = "Tage seit Ausbruch")+
        theme_minimal()+ 
        theme(legend.position="bottom")+
        labs(colour="")
      
    })
    
    output$hospital <- renderPlot({
      #if (is.null(v$data)) return()
      #plot(v$act_immune_people)
      ggplot(v, aes(x=seq(1:100))) + 
        coord_cartesian(xlim = c(0, 100), ylim = c(0, 0.07))+
        geom_line(aes(y=v$act_hosp_people, col="Anzahl Menschen die Platz in einem Krankenhaus haben"),lwd=2.5)+
        geom_line(aes(y=v$act_required_hosp, col="Anzahl Menschen die ins Krankenhaus müssen"),lwd=2.5)+
        theme_minimal()+
        labs(y = "Anzahl der Bevölkerung in Prozent")+
        labs(x = "Tage seit Ausbruch")+ 
        theme(legend.position="bottom")+
        labs(colour="")
      
    })
    
  })
  
  
  
  
  
}

shinyApp(ui, server)
