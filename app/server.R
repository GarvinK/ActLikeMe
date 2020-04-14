###############################################################################
# Act-Like-Me
#
# Author: Garvin Kruthof

###############################################################################

server <- function(input, output,session) {
  
  # Basic Numbers Page --------------------------------------------------------------
  


  

  
  # Number of hours in UI
  output$num_hours <- renderText({
    input$no_contacts
    
  })
  
  
  v <- reactiveValues(data = NULL)
  

  
  observeEvent(input$start_sim, {
    
    #v <- NLDoReport(10, "go", "act-immune-people")
    v <- actlikeme(personalcontacts =input$no_contacts,washing_hands=input$wash_hand, pub_transport=input$public_transport)
    output$text_intro <- renderText({paste("LET'S HAVE A LOOK AT HOW THE INFECTION
RATES WOULD HAVE BEEN DEVELOPED: If everyone acts in the same manner you do, the peak of the infection rate will be at day ",which.max(v$I),".",
                                           " Within the first ",length(v$I)," days, ",round(v$R[length(v$R)]*100), "% of the society might be immune
                                           against the virus.")})
    output$act_immune_people <- renderPlot({
      #if (is.null(v$data)) return()
      #plot(v$act_immune_people)
      ggplot(v, aes(x=seq(1:100))) + 
        coord_cartesian(xlim = c(0, 100), ylim = c(0, 1))+
        geom_line(aes(y=R, col="Immunity"),lwd=2.5)+ 
        geom_line(aes(y=I, col="Infections"),lwd=2.5)+
        geom_line(aes(y=D, col="Deaths"),lwd=2.5)+
        scale_y_continuous(labels=scales::percent)+
        
        labs(y = "Anzahl der Bevölkerung in Prozent")+
        labs(x = "Tage seit Ausbruch")+
        theme_minimal()+
        theme(legend.position="bottom")+
        labs(colour="")
      
    })
    
    if (length(which(v$H>0.05))>0) {
      overcap = paste("During the first ",length(v$H),"days",
                      "the domestic health system will suffer from undercapacity during ",length(which(v$H>0.05)),"days.")
    }
    else{
      overcap = "The domestic health system seems to be able to handle the development of the pandemic."
    }

 #   hosp_undercapacity= round(mean(v$act_hosp_people/v$act_required_hosp,na.rm = TRUE)*100, digit=2)
     output$hospital_test <- renderText({overcap})
     output$text_repeat <- renderText({"NOW TRY TO ADJUST THE SLIDERS AND HAVE A LOOK,
    HOW HUGE THE IMPACT OF THESE MEASURES ARE."})
    
     output$hospital <- renderPlot({
    #   #if (is.null(v$data)) return()
    #   #plot(v$act_immune_people)
     ggplot(v, aes(x=seq(1:100))) +
       coord_cartesian(xlim = c(0, 100), ylim = c(0, 0.3))+
       geom_line(aes(y=H, col="People requiring Hospital Beds"),lwd=2.5)+
       geom_line(aes(y=rep(0.05,100), col="Hospital Capacity"),lwd=1.5)+
       labs(y = "Anzahl der Bevölkerung in Prozent")+
       labs(x = "Tage seit Ausbruch")+
       theme_minimal()+
       theme(legend.position="bottom")+
       scale_y_continuous(labels=scales::percent)+
       labs(colour="")
       
     })
 

   
    
  })
  


  # Create Map Plot ---------------------------------------------------------

  

}
