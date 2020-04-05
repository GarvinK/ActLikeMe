library(shiny)
library(dplyr)
library(purrr)
library(readr)
library(stringr)
library(magrittr)
library(RNetLogo)

datasets <- read_tsv(file.path("data", "datasets.tsv"))

tweets <- read_tsv(file.path("data", "tweets.tsv")) %>%
  filter(dataset_id != "x")

users <- tweets %>%
  pull(screen_name) %>%
  unique() %>%
  sort()

ui <- fluidPage(
  tags$head(HTML('<link href="https://fonts.googleapis.com/css?family=Roboto+Mono" rel="stylesheet">')),
  tags$head(HTML('<style>* {font-size: 100%; font-family: Roboto Mono;}</style>')),
  tags$head(HTML('<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>')),
  fluidRow(
    column(1),
    column(4,
           h2("tidytuesday.rocks"),
           HTML("Test"),
                      br(),
           tabsetPanel(id = "selected_tab", type = "tabs", selected = "simulator",
                       tabPanel("About You", value = "simulator",
                                br(),
                                sliderInput("avg_relationships_per_person", "Wie gross ist Dein Bekanntenkreis?:",
                                            min = 0, max = 30, value = 5
                                ),
                                actionButton("start_sim", "Zeig mir mein Footprint")
                       ),
                       
                       tabPanel("Filter by Dataset", value = "dataset",
                                br(),
                                selectInput('dataset_name', 'Choose a dataset', rev(datasets$dataset_name), 
                                            selected = rev(datasets$dataset_name)[1]),
                                selectInput('dataset_sort_by', 'Sort tweets', c("Most recent", "Most likes", "Most retweets"), 
                                            selected = base::sample(c("Most recent", "Most likes", "Most retweets"), 1)),
                                
                       ),
                       tabPanel("Filter by User", value = "user",
                                br(),
                                selectizeInput("user_name", "Choose a user", users, selected = sample(users, 1)),
                                selectInput('user_sort_by', 'Sort tweets', c("Most recent", "Most likes", "Most retweets"), 
                                            selected = "Most recent"))
           )
    ),
    column(6,
           
           conditionalPanel(
             condition = "input.selected_tab == 'simulator'",
             h2("Dein Covid-19 Footprint"),
             p(uiOutput('dataset_links')), 
             #h3(textOutput('dataset_tweets_sorted_by')),
             plotOutput('act_immune_people')
             
           ),
           conditionalPanel(
             condition = "input.selected_tab == 'user'",
             h2(textOutput('user_name')),
             p(uiOutput('user_links')), 
             h3(textOutput('user_tweets_sorted_by')),
             uiOutput('embedded_user_tweets')
           )
    ),
    column(1)
  )
)

embed_tweet <- function(tweet) {
  tags$blockquote(class = "twitter-tweet", tags$a(href = tweet$status_url))
}

make_links <- function(urls, text, icon = NULL) {
  if (is.na(urls)) return("")
  split_urls <- unlist(str_split(urls, ","))
  if (length(split_urls) > 1) {
    text <- paste(text, 1:length(split_urls))
  }
  names(split_urls) <- text 
  links <- imap(split_urls, ~ shiny::a(.y, href = .x))
  c(icon, links)
}

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


shinyApp(ui, server)
