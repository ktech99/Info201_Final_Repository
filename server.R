library("dplyr")
library("ggplot2")
library("R.utils")
library("ggmap")
library("plotly")
police_data  <-
  data.table::fread("./data/Seattle_PD_data.bz2",
                    header = FALSE,
                    sep = ",")
seattle <-
  c(
    left = -122.459694,
    bottom = 47.4815352929,
    right = -122.224434,
    top = 47.734135
  )
seattle_map <-
  get_stamenmap(seattle, zoom = 13, maptype = "toner-lines")

police_data$date <- substr(police_data$V8, 1, 10)
police_data$time <- substr(police_data$V8, 12, 22)

server <- function(input, output, session) {
  AM_PM <- "AM"
  time_to_search <- 0
  reactive({
    time_to_search <- input$time_of_day
    if (input$time_of_day >= 12) {
      AM_PM <- "PM"
      if (input$time_of_day > 12) {
        time_to_search <- time_to_search - 12
      }
    }
  })
  
  ## Creates a plot to show frequency of reported crimes for the given time period in Seattle
  output$CrimeFrequencyPlot <- renderPlot({
    time_to_search <- input$time_of_day
    if (input$time_of_day >= 12) {
      AM_PM <- "PM"
      if (input$time_of_day > 12) {
        time_to_search <- time_to_search - 12
      }
    }
    crime_grouped <-
      group_by(police_data, V6) %>% dplyr::filter(
        input$Slider[1] <= substring(V8, 7, 10) & input$Slider[2] >= substring(V8, 7, 10) &
          grepl(AM_PM, time) &
          grepl(time_to_search, substring(time, 1, 3))
      ) %>% summarise(freq = n()) %>% dplyr::filter(freq >=
                                                      200)
    ggplot(data = crime_grouped, aes(
      x = V6,
      y = freq,
      width = .5,
      fill = V6
    )) +
      geom_bar(stat = 'identity',
               position = 'dodge',
               width = 400) +
      coord_flip() +
      theme(
        legend.position = "none",
        panel.background = element_blank(),
        axis.text.y = element_text(lineheight = 15)
      ) +
      labs(title = "Frequency of Crimes reported to Seattle PD", x = "Crime Groups")
  })
  
  
  ## Creates a density plot of crime on the map of Seattle for the given time period
  output$mapFreqencyPlot <- renderPlot({
    time_to_search <- input$time_of_day
    if (input$time_of_day >= 12) {
      AM_PM <- "PM"
      if (input$time_of_day > 12) {
        time_to_search <- time_to_search - 12
      }
    }
    crime_grouped <-
      group_by(police_data, V13, V14) %>% dplyr::filter(
        input$Slider[1] <= substring(V8, 7, 10) & input$Slider[2] >= substring(V8, 7, 10) &
          grepl(AM_PM, time) &
          grepl(time_to_search, substring(time, 1, 3))
      ) %>% summarise(freq = n()) %>% arrange(freq)
    
    
    
    crime_grouped$V13 <- as.numeric(as.character(crime_grouped$V13))
    crime_grouped$V14 <- as.numeric(as.character(crime_grouped$V14))
    
    ggmap(seattle_map) + geom_point(data = crime_grouped, aes(
      x = V13,
      y = V14,
      color = freq,
      size = freq
    )) + scale_color_gradient(low = "cyan",
                              high = "purple") + theme(axis.title.y = element_blank(), axis.title.x = element_blank()) + guides(colour = guide_legend(show = FALSE)) + coord_quickmap()
    
  })
  
  ## Creates a visualization of the crimes and its frequency for the year 2012
  output$crimes2012 <- renderPlot({
    data_2012 <-
      group_by(police_data, V6) %>% dplyr::filter(grepl('2012', V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq >=
                                                                                                                   200)
    ggplot(data = data_2012, aes(
      x = V6,
      y = freq,
      width = .5,
      fill = V6
    )) +
      geom_bar(stat = 'identity',
               position = 'dodge',
               width = 400) + ylim(0, 40000) + guides(fill = FALSE) +
      coord_flip() + labs(title = "Crime rates in 2012", x = "Crime Groups" ,y = "Frequency")
  })
  
  ## Creates a visualization of the crimes and its frequency for the year 2013
  output$crimes2013 <- renderPlot({
    data_2013 <-
      group_by(police_data, V6) %>% dplyr::filter(grepl('2013', V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq >=
                                                                                                                   200)
    ggplot(data = data_2013, aes(
      x = V6,
      y = freq,
      width = .5,
      fill = V6
    )) +
      geom_bar(stat = 'identity',
               position = 'dodge',
               width = 400) + ylim(0, 40000) + guides(fill = FALSE) +
      coord_flip() + labs(title = "Crime rates in 2013", x = "Crime Groups", y = "Frequency")
  })
  
  ## Creates a graph that compares crime between 2012 and 2013
  output$crime2013vs2012 <- renderPlotly({
    data_2013 <- group_by(police_data, V6) %>% dplyr::filter(grepl('2013', V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq >= 200) 
    sum_2013_2012 <- data.frame(sum(data_2013$freq))
    sum_2013_2012[1,"year"] <- 2013
    data_2012 <- group_by(police_data, V6) %>% dplyr::filter(grepl('2012', V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq >= 200)
    sum_2013_2012[nrow(sum_2013_2012) + 1,] = sum(data_2012$freq)
    sum_2013_2012[2, "year"] <- 2012
    plot_ly(sum_2013_2012, labels = sum_2013_2012$year, values = sum_2013_2012$sum.data_2013.freq, type = 'pie')%>%
      layout(title = 'Crimes Reported in 2013 after legalization of Marijuana in 2012',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

  })
  
  
  output$summaryHead <- renderText({
    paste0("Hello, and welcome to our project CID!")
  })
  output$summarybody1 <- renderUI({
    HTML(paste("Seattle is home to an engaged, innovative public that strives to make the city a better place to live. As part of Seattle's Open Data Initiative, the city wants to extend the ways that the public, organizations, businesses, and others 
               can benefit from the data it already collects. The aim of our project is to explore new potential uses for their city data and answer questions that make the city of Seattle a safer place to live. We wish to seek this by improving public understanding of City operations and other information concerning their communities.<br>"))
  })
  
  output$summarybody2 <- renderUI({
    HTML(paste("<B>Top 3 staggering facts from our investigation:</B><br><ul><li><h4>In 2012, Washington state voters approved I-502 legalizing the possession of small amounts of marijuana, and directing  the Washington State Liquor Control Board to develop a process for regulating marijuana production, processing, selling, and delivery.
               To corroborate this, our study proved that in 2011 there were <B> 295.6 violent offenses</B> reported per 100,000 Washington residents.In 2015, the rate
               had fallen to <B>284.4 violent offenses</B> per 100,000 people.</h4></li><li><h4>  Not including unreported cases, statistics show sexual assault is a frequent crime. In Washington state alone, 45 percent of women and 22 percent of men report having experienced sexual violence in their lifetime
               </h4></li><li><h4> The rate of property crime for Washington’s cities decreased from <B>3,698.9 offenses per 100,000</B> city inhabitants in 2014 to <B>3,463.8</B> in 2015. Nationally, the estimated rate of property crimes was 2,487.0 offenses per 100,000 city inhabitants."))
  })
  
}