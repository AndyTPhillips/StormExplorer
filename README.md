# Storm Explorer

**NOTE:** Requires Shiny 0.9.0 or later.

The dataset is taken from the U.S. National Oceanic and Atmospheric Administration's (NOAA) storm database. Only years 1991 - 2011 are included. 

Use the drop down to Filter by: Fatalities, Injuries, Property Damage, or Crop Damage. The mapped events will then be restricted to events where that variable is > 0 (i.e. Fatalities means that only events with at least one fatality are included).

Use the sliders to limit the widen or shorten the time range, between 1991 and 2011.

This project is heavily based on the Shiny superzip example: http://shiny.rstudio.com/gallery/superzip-example.html and uses Joe Cheng's leaflet package: https://github.com/jcheng5/leaflet-shiny

You can install this package with:
```
if (!require(devtools))
  install.packages("devtools")
devtools::install_github("jcheng5/leaflet-shiny")

```

