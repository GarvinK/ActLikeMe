fluidPage(
  tags$head(HTML('<link href="https://fonts.googleapis.com/css?family=Roboto+Mono" rel="stylesheet">')),
  tags$head(HTML('<style>* {font-size: 100%; font-family: Roboto Mono;}</style>')),
  tags$head(HTML('<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>')),
  fluidRow(
    column(1),
    column(4,
           h2("tidytuesday.rocks"),
           HTML(paste("<p><a href='https://github.com/rfordatascience/tidytuesday'>Tidy Tuesday</a>",
                      "is a weekly social data project in <a href='https://www.r-project.org/'>R</a>.",
                      "Every week <a href='https://twitter.com/thomas_mock'>@thomas_mock</a> and",
                      "<a href='https://twitter.com/R4DSCommunity'>@R4DSCommunity</a> post a new dataset",
                      "and ask R users to explore it and share their findings on Twitter with",
                      "<a href='https://twitter.com/search?src=typd&q=%23tidytuesday'>#TidyTuesday</a>.</p>")),
           HTML(paste("<p>Since the first dataset was posted on April 2nd, 2018, there are now",
                      "84 datasets and 3,069 #TidyTuesday tweets from 700 users! Use the options",
                      "below to filter the tweets by dataset or Twitter user and sort them by date, likes, and retweets.</p>")),
           HTML(paste("<p>tidytuesday.rocks is about 150 lines of R code and relies on your #TidyTuesday",
                      "tweets, which I scrape and manually label every few weeks. ",
                      "It is built with <a href='https://shiny.rstudio.com/'>Shiny</a> and <a href='https://rtweet.info/'>rtweet</a>",
                      "and its source code is <a href='https://github.com/nsgrantham/tidytuesdayrocks'>on GitHub</a>.</p>")),
           HTML(paste("<p>The response to tidytuesday.rocks has been amazing! It was even awarded ", 
                      "<a href='https://blog.rstudio.com/2019/04/05/first-shiny-contest-winners/'>a runner up spot in the 1st Shiny Contest</a>",
                      "among 136 submissions. \U0001F57A</p>")),
           HTML("<p>I'd love to hear your feedback, say hi <a href='https://twitter.com/nsgrantham'>@nsgrantham</a>.</p>"),
           p("Happy plotting!"),
           HTML("<p>(P.S. you may need to disable the DuckDuckGo Privacy Essentials browser extension for this website because it appears to block the JavaScript that embeds the tweets. If anybody knows a fix to this, please <a href='https://github.com/nsgrantham/tidytuesdayrocks/issues'>open an issue</a>!)</p>"),
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