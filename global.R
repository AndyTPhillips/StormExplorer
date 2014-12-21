library(dplyr)

allzips <- readRDS("storm.rds") 
allzips$latitude <- jitter(allzips$latitude) #stop many events from being piled on each other
allzips$longitude <- jitter(allzips$longitude)
allzips$zipcode <- formatC(allzips$zipcode, width=5, format="d", flag="0")


