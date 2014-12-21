library(shiny)
library(markdown)
library(leaflet)

# Choices for drop-downs
vars <- c(
  "Fatalities" = "fatalities",
  "Injuries" = "injuries",
  "Property Damage" = "totalpropdmg",
  "Crop Damage" = "totalcropdmg"
)


shinyUI(navbarPage("Storm Chaser", id="nav",

  tabPanel("Interactive map",
    div(class="outer",
      
      tags$head(
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),
      
      leafletMap("map", width="100%", height="100%",
        initialTileLayer = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
        initialTileLayerAttribution = HTML('Maps by <a href="http://www.mapbox.com/">Mapbox</a>'),
        options=list(
          center = c(37.45, -93.85),
          zoom = 4,
          maxBounds = list(list(15.961329,-129.92981), list(52.908902,-56.80481)) # Show US only
        )
      ),
      
      absolutePanel(id = "controls", class = "modal", fixed = TRUE, draggable = TRUE,
        top = 60, left = "auto", right = 20, bottom = "auto",
        width = 330, height = "auto",
        
        h2("Storm explorer"),
        
        selectInput("color", "Filter for:", vars),
        #selectInput("size", "Size", vars, selected = "adultpop"),
        conditionalPanel("input.color == 'superzip' || input.size == 'superzip'",
          # Only prompt for threshold when coloring or sizing by superzip
          numericInput("threshold", "SuperZIP threshold (top n percentile)", 5)
        ),
        
        sliderInput("range", 
                    label = "Select Year Range:", format="####",
                    min = 1991, max = 2011, value = c(2010, 2011)),
        
        #plotOutput("histCentile", height = 200),
        plotOutput("scatterCollegeIncome", height = 250)
      ),
      
      tags$div(id="cite",
        'Data compiled for ', tags$em('NOAA Storm Database'), ' by National Weather Service'
      )
    )
  ),
  
  # Second tab -------------------------------------------------------------------  
  
  tabPanel('About',
           
           fluidRow(
             column(6, offset = 2,
                    includeMarkdown('README.md'))
           )  
  ),    
  
  conditionalPanel("false", icon("crosshair"))
))
