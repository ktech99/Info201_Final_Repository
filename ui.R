library(shiny)
library(shinythemes)

  ui <-  pageWithSidebar(
    
    
    # App title ----
    headerPanel("C.I.D (Crime Investigation Department)"),
    
    # Sidebar panel for inputs ----
    sidebarPanel(
  
      sliderInput(
        "Slider",
        "Year",
        value = 2014,
        min = 2010,
        max = 2017
        
      ),
      
      
      dateRangeInput('dates', label = "Date Range",width = 380,
                     start = '2014-01-01', end = '2015-01-01',
                     min = "2013-01-01", max = "2016-08-01"
      ),

      # create a slder-input widget for time of day selection
      sliderInput('time_of_day','Time of Day', min = 0, max = 23,width = 380,
                  value = c(0,23), step = 1),
      
      # create a submit-button for user explicitly confirm data input
      submitButton(text = "Submit",icon =icon('filter'))
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Plot", plotOutput("CrimeFrequencyPlot"), plotOutput("mapFreqencyPlot")),
                  tabPanel("Summary", verbatimTextOutput("summary")),
                  tabPanel("Table", tableOutput("table"))
      )
      
     # plotOutput("ShapePlot"),
      #p(textOutput("shapeCaption"))
    )
  )
