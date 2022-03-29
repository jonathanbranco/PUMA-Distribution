#Setup ----
  #Checks if needed libraries are installed, install then if not and loads them afterwards
  libraries<-function(...) {
    libs<-unlist(list(...))
    req<-unlist(lapply(libs,require,character.only=TRUE))
    need<-libs[req==FALSE]
    if(length(need)>0){ 
      install.packages(need)
      lapply(need,require,character.only=TRUE)
    }
  }
  libraries("rstudioapi","shiny","leaflet","htmlwidgets")
  rm(libraries)
  
  #Sets Working directory as the one the script is on
  current_path <- getActiveDocumentContext()$path 
  setwd(dirname(current_path))
  rm(current_path)

#Preparing data ----
  #Reads data 
  record <- read.table('record_database.csv', sep=",", header=T, stringsAsFactors = T)
  
  #Remove rows with empty values
  record_clean <- na.omit(record)
  
  #Select only subject species
  record_clean <- subset(record_clean, Species=="Progne subis")
  
  #Create Date column (D/M/Y)
  record_clean$Date <- paste(record_clean$Day,record_clean$Month,record_clean$Year, sep = "/")

#Mapping observations ----
  #Generates Map Layer
  map <- leaflet(options = leafletOptions(minZoom = 3,maxZoom = 7)) %>% 
            addProviderTiles(provider = "Esri.NatGeoWorldMap") %>%
            addProviderTiles(provider = "Stamen.TonerLines") %>%
            setView(lng = -55,lat = -15, zoom = 4) %>%
            setMaxBounds(lng1 = -55 + 35, 
                         lat1 = -15 + 35, 
                         lng2 = -55 - 35, 
                         lat2 = -15 - 35)

  #Add observation markers
  map <- map %>% addAwesomeMarkers(lng = record_clean$Longitude,
                                   lat = record_clean$Latitude,
                                   popup = paste(record_clean$City_Name,
                                                 " - ",
                                                 record_clean$State_ID,
                                                 "<br>",
                                                 record_clean$Date,
                                                 sep="")
                                   )
  
  map

#exporting map
saveWidget(map, "PUMA - Distribution.html")
