library(shiny)
library("shinythemes")
library("shinycssloaders")
library("plotly")
library(markdown)

 ui <- fluidPage(
   theme = shinytheme("darkly"),
   titlePanel(
     fluidRow(
       column(9,"C.I.D (Crime Investigation Department)"), 
       column(2, img(height = 200, width = 200, src = "C.I.D._(TV_series).png"))
     )
   ),
   fluidRow(
      navbarPage( 
        tabPanel("Nothing"),
        tabPanel("Summary",
                 includeMarkdown("summary.md")
          ),
          tabPanel("Plot",
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
                   mainPanel(
                     withSpinner(plotOutput("CrimeFrequencyPlot")), 
                     plotOutput("mapFreqencyPlot")
                   )
                 ),
                  
          tabPanel("Marijuana legalization", 
                   mainPanel(
                     withSpinner(plotOutput("crimes2012")), plotOutput("crimes2013"), plotlyOutput("crime2013vs2012"))
                   )
      )
  )
)
