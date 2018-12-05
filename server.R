library("dplyr")
library("ggplot2")
library("R.utils")
police_data  <- data.table::fread("./data/Seattle_PD_data.bz2", header = FALSE, sep=",")


server <- function(input, output, session) {

  output$CrimeFrequencyPlot <- renderPlot({
    crime_grouped <- group_by(police_data, V6) %>% dplyr::filter(grepl(input$Slider,V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq>=200)
    ggplot(data = crime_grouped, aes(
      x = V6,
      y = freq,
      width = .5,
      fill = V6 
    )) +
      geom_bar(stat = 'identity', position = 'dodge', width = 400) +
      coord_flip() +
      theme(legend.position = "none",
            panel.background = element_blank(),
            axis.text.y = element_text( lineheight = 15))+
      labs(title = "Frequency of Crimes reported to Seattle PD")
  }) 
  
  output$table <- renderTable({
    summary(police_data)
  })
  
  output$mapFreqencyPlot <- renderPlot({
    crime_grouped <- group_by(police_data, V13, V14) %>% dplyr::filter(grepl("2015",V8)) %>% summarise(freq = n())
    ggplot(crime_grouped) +
      geom_tile(aes(
        x = V14,
        y = V13,
        fill = freq
      )) + scale_fill_gradient(low = "white", high = "red")  + ggtitle("North America 1986 Airtemp")
  })
  
  output$summaryHead <- renderText({
    paste0("Hello, and welcome to our project CID!")
  })
  output$summarybody <- renderText({
    paste("Seattle is home to an engaged, innovative public that strives to make the city a better place to live. As part of Seattle's Open Data Initiative, the city wants to extend the ways that the public, organizations, businesses, and others 
can benefit from the data it already collects. The aim of our project is to explore new potential uses for their city data and answer questions that make the city of Seattle a safer place to live.We wish to seek this by improving public understanding of City operations and other information concerning their communities.", "For instance, in 2012, Washington state voters approved I-502 legalizing the possession of small amounts of marijuana, and directing  the Washington State Liquor Control Board to develop a process for regulating marijuana production, processing, selling, and delivery.
To corroborate this, our study proved that in 2011 there were 295.6 violent offenses reported per 100,000 Washington residents. In 2015, the rate
had fallen to 284.4 violent offenses per 100,000 people.", sep = "\n")
  })

}
