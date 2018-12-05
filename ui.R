library(shiny)
library("shinythemes")
library(plotly)

ui <- fluidPage(
      theme = shinytheme("superhero"),
      pageWithSidebar(
  
  
  # App title ----
  titlePanel(
    fluidRow(
      column(9,"C.I.D (Crime Investigation Department)"), 
      column(2, img(height = 120, width = 200, src = "C.I.D._(TV_series).png"))
    )
  ),
  
  # Sidebar panel for inputs ----
  sidebarPanel(
    
    sliderInput(
      "Slider",
      "Year",
      value = c(2010, 2017),
      min = 2010,
      max = 2017
      
    ),
    
    # create a slder-input widget for time of day selection
    sliderInput('time_of_day','Time of Day', min = 0, max = 23,width = 380,
                value = 12, step = 1),
    
    # create a submit-button for user explicitly confirm data input
    submitButton(text = "Submit",icon =icon('filter'))
  ),
  
  # Main panel for displaying outputs ----
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("Summary",h1(span(textOutput("summaryHead"), style="color:white")), h4(span(uiOutput("summarybody1"), style = "color:white"), h4(span(uiOutput("summarybody2")),style = "color:white"))),
                tabPanel("Plot", plotOutput("CrimeFrequencyPlot"), plotOutput("mapFreqencyPlot")),
                tabPanel("Marijuana legalization", plotOutput("crimes2012"), plotOutput("crimes2013"), plotlyOutput("crime2013vs2012"))
    )
    
    # plotOutput("ShapePlot"),
    #p(textOutput("shapeCaption"))
  )
)
)
