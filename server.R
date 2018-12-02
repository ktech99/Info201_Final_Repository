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
  

}
