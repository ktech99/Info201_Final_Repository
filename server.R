library("dplyr")
library("ggplot2")
library("R.utils")
police_data  <-
  data.table::fread("./data/Seattle_PD_data.bz2",
                    header = FALSE,
                    sep = ",")
seattle_map <-
  get_stamenmap(seattle, zoom = 13, maptype = "toner-lines")

police_data$date <- format(strptime(police_data$V8, "%d/%m/%Y %I:%M:%S %p"), "%d/%m/%y")
  
server <- function(input, output, session) {
  output$CrimeFrequencyPlot <- renderPlot({
    crime_grouped <-
      group_by(police_data, V6) %>% dplyr::filter(grepl(input$Slider, V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq >=
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
      labs(title = "Frequency of Crimes reported to Seattle PD")
  })
  
  output$table <- renderTable({
    summary(police_data)
  })
  
  output$mapFreqencyPlot <- renderPlot({
    crime_grouped <-
      group_by(police_data, V13, V14) %>% dplyr::filter(grepl(input$Slider, V8)) %>% summarise(freq = n()) %>% arrange(freq)
    seattle <-
      c(
        left = -122.459694,
        bottom = 47.4815352929,
        right = -122.224434,
        top = 47.734135
      )

    
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
      coord_flip()
  })
  
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
      coord_flip()
  })
  
  
  output$summaryHead <- renderText({
    paste0("Hello, and welcome to our project CID")
  })
  output$summarybody <- renderText({
    paste0("The aim of our project is analyze data from UWPD, and draw conclusions from this data")
  })
  
}
