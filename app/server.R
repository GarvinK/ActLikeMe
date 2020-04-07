###############################################################################
# Act-Like-Me
#
# Author: Garvin Kruthof

###############################################################################

server <- function(input, output,session) {
  
  # Basic Numbers Page --------------------------------------------------------------
  


  

  
  # Number of hours in UI
  output$num_hours <- renderText({
    input$social_distancing
    
  })
  
  
  v <- reactiveValues(data = NULL)
  
  nl.path <- "/home/garvin_kruthof/netlogo/app"
  nl.jarname <- "netlogo-6.0.4.jar"
  NLStart(nl.path, nl.jarname=nl.jarname,gui=FALSE)
  model.path <- "/srv/shiny-server/Covid19/model/prototype_simple.nlogo"
  NLLoadModel(model.path)
  
  observeEvent(input$start_sim, {
    NLCommand(paste('set probability-of-contact ',toString(40-input$probability_of_contact),sep=""))
    
    NLCommand("setup")
    #NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    NLCommand("setup-experiment")
    #NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    #v <- NLDoReport(10, "go", "act-immune-people")
    v <- NLDoReport(50, "go", c("act-immune-people","act-dead-people","act-infect-people","act-hosp-people","act-required-hosp"),
                    as.data.frame=TRUE, df.col.names=c("act_immune_people","act_dead_people","act_infect_people","act_hosp_people","act_required_hosp "))
    
    output$act_immune_people <- renderPlot({
      #if (is.null(v$data)) return()
      #plot(v$act_immune_people)
      ggplot(v, aes(x=seq(1:50))) + 
        coord_cartesian(xlim = c(0, 50), ylim = c(0, 1))+
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
      ggplot(v, aes(x=seq(1:50))) + 
        coord_cartesian(xlim = c(0, 50), ylim = c(0, 0.07))+
        geom_line(aes(y=v$act_hosp_people, col="Anzahl Menschen die Platz in einem Krankenhaus haben"),lwd=2.5)+
        geom_line(aes(y=v$act_required_hosp, col="Anzahl Menschen die ins Krankenhaus müssen"),lwd=2.5)+
        theme_minimal()+
        labs(y = "Anzahl der Bevölkerung in Prozent")+
        labs(x = "Tage seit Ausbruch")+ 
        theme(legend.position="bottom")+
        labs(colour="")
      
    })
    
  })
  


  # Create Map Plot ---------------------------------------------------------

  

}
