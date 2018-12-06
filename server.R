library("dplyr")
library("ggplot2")
library("R.utils")
library("ggmap")
library("plotly")
police_data  <-
  data.table::fread("./data/Seattle_PD_data.bz2",
                    header = FALSE,
                    sep = ",")
## For the purpose of this project we have decreased the size of the dataset to prioritize fast processing
police_data <- sample_n(full_data, 10000)

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
      ) %>% summarise(freq = n())
    
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
      group_by(police_data, V6) %>% dplyr::filter(grepl('2012', V8)) %>% summarise(freq = n())
    ggplot(data = data_2012, aes(
      x = V6,
      y = freq,
      width = .5,
      fill = V6
    )) +
      geom_bar(stat = 'identity',
               position = 'dodge',
               width = 400) + ylim(0, 1500) + guides(fill = FALSE) +
      coord_flip() + labs(title = "Crime rates in 2012", x = "Crime Groups" ,y = "Frequency")
  })
  
  ## Creates a visualization of the crimes and its frequency for the year 2013
  output$crimes2013 <- renderPlot({
    data_2013 <-
      group_by(police_data, V6) %>% dplyr::filter(grepl('2013', V8)) %>% summarise(freq = n())
    ggplot(data = data_2013, aes(
      x = V6,
      y = freq,
      width = .5,
      fill = V6
    )) +
      geom_bar(stat = 'identity',
               position = 'dodge',
               width = 400) + ylim(0, 1500) + guides(fill = FALSE) +
      coord_flip() + labs(title = "Crime rates in 2013", x = "Crime Groups", y = "Frequency")
  })
  
  ## Creates a graph that compares crime between 2012 and 2013
  output$crime2013vs2012 <- renderPlotly({
    data_2013 <- group_by(police_data, V6) %>% dplyr::filter(grepl('2013', V8)) %>% summarise(freq = n()) 
    sum_2013_2012 <- data.frame(sum(data_2013$freq))
    sum_2013_2012[1,"year"] <- 2013
    data_2012 <- group_by(police_data, V6) %>% dplyr::filter(grepl('2012', V8)) %>% summarise(freq = n())
    sum_2013_2012[nrow(sum_2013_2012) + 1,] = sum(data_2012$freq)
    sum_2013_2012[2, "year"] <- 2012
    plot_ly(sum_2013_2012, labels = sum_2013_2012$year, values = sum_2013_2012$sum.data_2013.freq, type = 'pie')%>%
      layout(title = 'Crimes Reported in 2013 after legalization of Marijuana in 2012',
             xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))

  })
  
}