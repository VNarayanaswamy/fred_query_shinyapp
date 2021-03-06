# Author: Justin Skillman
# Note: Please change the apikey in server() if you have your own FRED account
#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above (in Rstudio).
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(jsonlite)

# Define UI for data download app 
ui <- fluidPage(
  
  # Application title
  titlePanel("FRED Data Query Tool"),
 
  # Sidebar layout with input and output definitions
  sidebarLayout(
    
    # Sidebar panel for inputs
    sidebarPanel(
      
      textInput("usersrchinput", label = h3("Search for a dataset:"), value = "Enter text..."),
      actionButton("update", "Search"),
      
      # Input: Choose dataset 
      uiOutput("choosedata"),
      uiOutput("choosedate1"),
      uiOutput("choosedate2"),
      
      # Download Button
      uiOutput("download")
      
    ),
    
    # Main panel for displaying outputs 
    mainPanel(
      
      tableOutput("table")
      
    )
    
  )
)

# Define server logic to display and download selected file 
server <- function(input, output) {
  
  apikey <- 0000000000000000000000  # Change this is you are new user
  
  # Pull series info related to search
  searchedseries <-  eventReactive(input$update, {fromJSON(
    paste0("https://api.stlouisfed.org/fred/series/search?",
           "search_text=", input$usersrchinput, 
           "&api_key=", apikey,
           "&file_type=json")
  )$seriess}, ignoreNULL = TRUE)
  
  
  # Render top ten results
  output$table <- renderTable(striped=TRUE,
    options = list(width="100"), {
    topten <- searchedseries()
    topten <- topten[,c ("id",
               "title",
               "frequency",
               "observation_start",
               "observation_end",
               "popularity",
               "seasonal_adjustment",
               "notes"
               )]
    topten <- topten[order(
      topten$popularity, decreasing = T), ]
    topten[1:10, ]
  })
  
  output$choosedata <- renderUI({
    topten <- searchedseries()
    topten <- topten[,c ("id",
                         "title",
                         "frequency",
                         "observation_start",
                         "observation_end",
                         "popularity",
                         "seasonal_adjustment",
                         "notes"
    )]
    topten <- topten[order(
      topten$popularity, decreasing = T), ]
    names <- topten$id[1:10] 
    selectInput("dataset", label = h3("Choose a dataset:"),
                choices = c("Choose one...",names))
  })
  
  output$choosedate1 <- renderUI({
    topten <- searchedseries()
    topten <- topten[,c ("id",
                         "title",
                         "frequency",
                         "observation_start",
                         "observation_end",
                         "popularity",
                         "seasonal_adjustment",
                         "notes"
    )]
    topten <- topten[order(
      topten$popularity, decreasing = T), ]
    names <- topten$id[1:10] 
    textInput("choosedate1", label="", value = "Enter starting date...")
  })
  
  output$choosedate2 <- renderUI({
    topten <- searchedseries()
    topten <- topten[,c ("id",
                         "title",
                         "frequency",
                         "observation_start",
                         "observation_end",
                         "popularity",
                         "seasonal_adjustment",
                         "notes"
    )]
    topten <- topten[order(
      topten$popularity, decreasing = T), ]
    names <- topten$id[1:10] 
    textInput("choosedate2", label="", value = "Enter ending date...")
  })
  
  output$download <- renderUI({
    topten <- searchedseries()
    topten <- topten[,c ("id",
                         "title",
                         "frequency",
                         "observation_start",
                         "observation_end",
                         "popularity",
                         "seasonal_adjustment",
                         "notes"
    )]
    topten <- topten[order(
      topten$popularity, decreasing = T), ]
    names <- topten$id[1:10] 
    downloadButton("downloadData", "Download")
  })
  
  # Pull data for choice and show in shiny
  pulledseries <- eventReactive(input$choosedate2, {fromJSON(
    paste0("https://api.stlouisfed.org/fred/series/observations?",
           "series_id=", input$dataset, 
           "&observation_start=", input$choosedate1,
           "&observation_end=", input$choosedate2,
           "&api_key=", apikey,
           "&output_type=2",
           "&file_type=json")
  )$observations}, ignoreNULL = TRUE)

 # Option to download
  output$downloadData <- eventReactive(input$choosedate2, {downloadHandler(
    filename = function() {
      paste("inputdataset", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(pulledseries(), file, row.names = FALSE)
    }
  )}, ignoreNULL = TRUE)
 
}

# Create Shiny app
shinyApp(ui, server)
