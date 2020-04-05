library(RNetLogo)
server <-function(input, output) {
  
  v <- reactiveValues(data = NULL)
  
  nl.path <- "/home/garvin_kruthof/test/NetLogo 6.0.4/app"
  nl.jarname <- "netlogo-6.0.4.jar"
  NLStart(nl.path, nl.jarname=nl.jarname,gui=FALSE)
  model.path <- "/home/garvin_kruthof/Covid19/model/fixed_number_prototype.nlogo"
  NLLoadModel(model.path)
  
  observeEvent(input$start_sim, {
    #NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    NLCommand("setup")
    #NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    NLCommand("setup-experiment")
    NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    #v <- NLDoReport(10, "go", "act-immune-people")
    v <- NLDoReport(10, "go", c("act-immune-people","act-dead-people"),
                    as.data.frame=TRUE, df.col.names=c("act_immune_people","act_dead_people"))
    
    output$act_immune_people <- renderPlot({
      if (is.null(v$data)) return()
      plot(v$act_immune_people)
    })
    
  })
  
}