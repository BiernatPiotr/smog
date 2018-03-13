# data handle
library(dplyr)

# load weather data 
read.delim(
  file = 'data/weather.txt',
  sep = ';',
  header = T, 
  stringsAsFactors = FALSE
) -> 
  dfWeather

# quick preview of data
glimpse(dfWeather)

# there are the same parameters in different units, so we chose only one of them
dfWeather %>%
  select(
    date, # date in format YYYY-MM-DD
    time, # hours in format HH00
    tempC, # temperature in degrees Celsius
    FeelsLikeC, #feels like temperature in degrees Celsius
    windspeedKmph, # wind speed in kilometers per hour
    winddirDegree, # wind direction in degrees
    humidity, #humidity in percentage
    pressure, # atmospheric pressure in millibars 
    visibility, # visibility in kilometers
    cloudcover, # cloud cover amount in percentage
    precipMM # precipitation in millimeters
  ) ->
  dfWeather

# date format
dfWeather$date <-  as.Date(dfWeather$date)

# check
glimpse(dfWeather)

# load smog data, as we analyse only one station, we select data only for it
read.csv2(
  file = 'data/2015_PM10_1g.csv',
  sep = ';',
  header=TRUE,
  stringsAsFactors = FALSE
) %>% 
  select(Date,PM10 = MpKrakAlKras) ->
  dfSmog

# and 2016
read.csv2(
  file = 'data/2016_PM10_1g.csv',
  sep = ';',
  header=TRUE,
  stringsAsFactors = FALSE
) %>% 
  select(Date, PM10 = MpKrakAlKras.PM10.1g) %>%
  rbind(dfSmog) ->
  dfSmog

# quick preview
glimpse(dfSmog)

# prepare date and hours format for join
dfSmog %>%
  mutate(
    Hour = as.numeric(sub('.*([0-9]{2}):[0-9]{2}','\\1',Date))*100,
    Date = as.Date(Date)
  ) ->
  dfSmog

# check
glimpse(dfSmog)

# join data
dfWeather %>%
  left_join(dfSmog, by = c('date'='Date','time'='Hour')) ->
  dfAllData

# quick preview
glimpse(dfAllData)

# for future use we add levels for PM10, here function with boundaries
fAirPollution <- function(iPM10) {
  head(
    c('Very good','Good','Moderate','Sufficient','Bad','Very bad')[c(21,61,101,141,201,9999) >= iPM10]
    ,1
  )
}

# now we add variables for year, month, day and pollution levels
dfAllData %>%
  rowwise() %>%
  mutate(
    year = format(date, '%Y'),
    month = format(date, '%m'),
    day = format(date, '%d'),
    AirQuality = factor(fAirPollution(PM10), levels = c('Very good','Good','Moderate','Sufficient','Bad','Very bad'), ordered = TRUE)
  ) %>%
  ungroup() %>%
  na.omit() ->
  dfAllData

# check
glimpse(dfAllData)

# some cleaning
rm(list = c('dfSmog','dfWeather'))