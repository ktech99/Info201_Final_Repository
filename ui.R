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
        
      )
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      plotOutput("CrimeFrequencyPlot")
     # plotOutput("ShapePlot"),
      #p(textOutput("shapeCaption"))
    )
  )
