library(shiny)
library(leaflet)
library(RColorBrewer)
library(scales)
library(lattice)
library(dplyr)

# Leaflet bindings are a bit slow; for now we'll just sample to compensate
set.seed(100)
zipdata <- allzips[sample.int(nrow(allzips), 10000),] 
# By ordering by centile, we ensure that the (comparatively rare) SuperZIPs
# will be drawn last and thus be easier to see
zipdata <- zipdata[order(zipdata$centile),]

shinyServer(function(input, output, session) {
  
  ## Interactive Map ###########################################

  # Create the map
  map <- createLeafletMap(session, "map")

  # A reactive expression that returns the set of zips that are
  # in bounds right now
  zipsInBounds <- reactive({
    if (is.null(input$map_bounds))
      return(zipdata[FALSE,])
    bounds <- input$map_bounds
    latRng <- range(bounds$north, bounds$south)
    lngRng <- range(bounds$east, bounds$west)
    
    subset(zipdata,
      latitude >= latRng[1] & latitude <= latRng[2] &
        longitude >= lngRng[1] & longitude <= lngRng[2])
  })
  
  
  # session$onFlushed is necessary to work around a bug in the Shiny/Leaflet
  # integration; without it, the addCircle commands arrive in the browser
  # before the map is created.
  session$onFlushed(once=TRUE, function() {
    paintObs <- observe({
      colorBy <- input$color
      sizeBy <- "centile" 
      startyear <- input$range[1] #slider min
      endyear <- input$range[2] #slider max
      
      zipdata <- allzips[sample.int(nrow(allzips), 10000),] #limit to 10,000 if the map is zoomed 
      #out enough to show the whole set
      
      if (colorBy == "fatalities"){
        zipdata <- filter(zipdata, fatalities > 0, year >= startyear, year <= endyear)
      } else if (colorBy == "injuries"){
        zipdata <- filter(zipdata, injuries > 0, year >= startyear, year <= endyear)
      } else if (colorBy == "totalpropdmg"){
        zipdata <- filter(zipdata, totalpropdmg > 0, year >= startyear, year <= endyear)
      } else if (colorBy == "totalcropdmg"){
        zipdata <- filter(zipdata, totalcropdmg > 0, year >= startyear, year <= endyear)
      }
       
        
      
      
  
      colorData <- if (colorBy == "superzip") {
        as.numeric(allzips$centile > (100 - input$threshold))
      } else {
        allzips[[colorBy]]
      }
      colors <- brewer.pal(7, "Spectral")[cut(colorData, 7, labels = FALSE)]
      colors <- colors[match(zipdata$zipcode, allzips$zipcode)]
      
      # Clear existing circles before drawing
      map$clearShapes()
      # Draw in batches of 1000; makes the app feel a bit more responsive
      chunksize <- 1000
      for (from in seq.int(1, nrow(zipdata), chunksize)) {
        to <- min(nrow(zipdata), from + chunksize)
        zipchunk <- zipdata[from:to,]
        # Bug in Shiny causes this to error out when user closes browser
        # before we get here
        try(
          map$addCircle(
            zipchunk$latitude, zipchunk$longitude,
            (zipchunk[[sizeBy]] / max(allzips[[sizeBy]])) * 30000,
            zipchunk$zipcode,
            list(stroke=FALSE, fill=TRUE, fillOpacity=0.4),
            list(color = colors[from:to])
          )
        )
      }
    })
    
    # TIL this is necessary in order to prevent the observer from
    # attempting to write to the websocket after the session is gone.
    session$onSessionEnded(paintObs$suspend)
  })
  
  # Show a popup at the given location
  showZipcodePopup <- function(zipcode, lat, lng) {
    selectedZip <- allzips[allzips$zipcode == zipcode,]
    content <- as.character(tagList(
      tags$h4("Event:", selectedZip$event),
      tags$h4("Year:", selectedZip$year),
      tags$h6(" ", selectedZip$remarks),
      tags$strong(HTML(sprintf("%s, %s %s",
        selectedZip$countyname, selectedZip$state, selectedZip$zipcode
      ))), tags$br(),
      sprintf("Total Property Damage: %s", dollar(selectedZip$totalpropdmg)), tags$br(),
      sprintf("Total Crop Damage: %s", dollar(selectedZip$totalcropdmg)), tags$br(),
      sprintf("Total Injuries: %s", selectedZip$injuries), tags$br(),
      sprintf("Total Fatalities: %s", selectedZip$fatalities)
    ))
    map$showPopup(lat, lng, content, zipcode)
  }

  # When map is clicked, show a popup with city info
  clickObs <- observe({
    map$clearPopups()
    event <- input$map_shape_click
    if (is.null(event))
      return()
    
    isolate({
      showZipcodePopup(event$id, event$lat, event$lng)
    })
  })
  
  session$onSessionEnded(clickObs$suspend)
  

  
 
  

})
