library("dplyr")
library("ggplot2")
library("R.utils")
library("ggmap")
library("devtools")
# devtools::install_github("dkahle/ggmap", ref = "tidyup")


police_data  <-
  data.table::fread("./data/Seattle_PD_data.bz2",
                    header = FALSE,
                    sep = ",")
data_2012 <-
  group_by(police_data, V6) %>% dplyr::filter(grepl('2012', V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq >=
                                                                                                               200)
data_2013 <-
  group_by(police_data, V6) %>% dplyr::filter(grepl('2013', V8)) %>% summarise(freq = n()) %>% dplyr::filter(freq >=
                                                                                                               200)

plot_2012 <- ggplot(data = data_2012, aes(
  x = V6,
  y = freq,
  width = .5,
  fill = V6
)) +
  geom_bar(stat = 'identity',
           position = 'dodge',
           width = 400) +
  coord_flip()

plot_2013 <- ggplot(data = data_2013, aes(
  x = V6,
  y = freq,
  width = .5,
  fill = V6
)) +
  geom_bar(stat = 'identity',
           position = 'dodge',
           width = 400) +
  coord_flip()


