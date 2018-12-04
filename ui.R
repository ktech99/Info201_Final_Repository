library(shiny)

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
      
      
      sliderInput('month','Month', min = 1, max = 12,width = 380,
                  value =1, step = 1),

      # create a slder-input widget for time of day selection
      sliderInput('time_of_day','Time of Day', min = 0, max = 23,width = 380,
                  value = 12, step = 1),
      
      # create a submit-button for user explicitly confirm data input
      submitButton(text = "Submit",icon =icon('filter'))
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      tabsetPanel(type = "tabs",
                  tabPanel("Summary",h1(textOutput("summaryHead"), style="color:gray"), h2(textOutput("summarybody"))),
                  tabPanel("Plot", plotOutput("CrimeFrequencyPlot"), plotOutput("mapFreqencyPlot")),
                  tabPanel("Marijuana legalization", plotOutput("crimes2012"), plotOutput("crimes2013")),
                  tabPanel("Table", tableOutput("table"))
      )
      
     # plotOutput("ShapePlot"),
      #p(textOutput("shapeCaption"))
    )
  )
