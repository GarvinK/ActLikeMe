

server <- function(input, output, session) {
  v <- reactiveValues(data = NULL)
  chosen_dataset <- reactive({
    datasets %>%
      filter(dataset_name == input$dataset_name) %>%
      transpose() %>%
      extract2(1)
  })
  
  dataset_tweets <- reactive({
    tweets %>%
      filter(dataset_id == chosen_dataset()$dataset_id) %>%
      select(status_url, created_at, favorite_count, retweet_count)
  })
  
  sorted_dataset_tweets <- reactive({
    switch(input$dataset_sort_by,
           "Most recent"   = dataset_tweets() %>% arrange(desc(created_at)),
           "Most likes"    = dataset_tweets() %>% arrange(desc(favorite_count)),
           "Most retweets" = dataset_tweets() %>% arrange(desc(retweet_count)))
  })
  
  nl.path <- "/home/garvin_kruthof/test/NetLogo 6.0.4/app"
  nl.jarname <- "netlogo-6.0.4.jar"
  NLStart(nl.path, nl.jarname=nl.jarname,gui=FALSE)
  model.path <- "/home/garvin_kruthof/Covid19/model/fixed_number_prototype.nlogo"
  NLLoadModel(model.path)
  
  observeEvent(input$start_sim, {
    NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    NLCommand("setup")
    #NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    NLCommand("setup-experiment")
    NLCommand(paste('set avg-relationships-per-person ',toString(input$avg_relationships_per_person),sep=""))
    
    #v <- NLDoReport(10, "go", "act-immune-people")
    v <- NLDoReport(100, "go", c("act-immune-people","act-dead-people"),
                    as.data.frame=TRUE, df.col.names=c("act_immune_people","act_dead_people"))
    
    output$act_immune_people <- renderPlot({
      #if (is.null(v$data)) return()
      plot(v$act_immune_people)
    })
    
  })
  
  
  
  
  output$dataset_tweets_sorted_by <- reactive({paste("Tweets sorted by", tolower(input$dataset_sort_by))})
  
  output$dataset_name <- renderText({chosen_dataset()$dataset_name})
  
  output$dataset_links <- renderUI({
    tagList(make_links(chosen_dataset()$dataset_files, "Data", "\U0001F4BE"),        # floppy disk
            make_links(chosen_dataset()$dataset_articles, "Article", "\U0001F5DE"),  # rolled up newspaper
            make_links(chosen_dataset()$dataset_sources, "Source", "\U0001F4CD"))    # red pin
  })
  
  output$embedded_dataset_tweets <- renderUI({
    tagList(map(transpose(sorted_dataset_tweets()), embed_tweet), 
            tags$script('twttr.widgets.load(document.getElementById("tweets"));'))
  })
  
  user_tweets <- reactive({
    tweets %>%
      filter(screen_name == input$user_name) %>%
      select(status_url, created_at, favorite_count, retweet_count)
  })
  
  sorted_user_tweets <- reactive({
    switch(input$user_sort_by,
           "Most recent"   = user_tweets() %>% arrange(desc(created_at)),
           "Most likes"    = user_tweets() %>% arrange(desc(favorite_count)),
           "Most retweets" = user_tweets() %>% arrange(desc(retweet_count)))
  })
  
  output$user_tweets_sorted_by <- reactive({paste("Tweets sorted by", tolower(input$user_sort_by))})
  
  output$user_name <- renderText({input$user_name})
  
  output$user_links <- renderUI({
    tagList(make_links(paste0("https://twitter.com/", input$user_name), "Twitter", "\U0001F4AC"))  # speech bubble
  })
  
  output$embedded_user_tweets <- renderUI({
    tagList(map(transpose(sorted_user_tweets()), embed_tweet), 
            tags$script('twttr.widgets.load(document.getElementById("tweets"));'))
  }) 
}

