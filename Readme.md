# Can we predict the smog only on the basis of the weather forecast?

## Table of context

[Introduction](#introduction)  
[Data sources](#data-sources)  
[Data exploration](#data-exploration)  
[PM10 modelling](#pm10-modelling)  
[Air pollution modelling](#air-pollution-modelling)  
[What's next?](#whats-next)  

## Introduction

Smog is a very big problem in Poland. Especially in a winter there are warnings in a mass media almost every day. The air here is one of the worst in Europe. There are mainly two things responsible for this state: transport and coal-heating. A lot of people argue about which of these sources has bigger impact on air pollution, but this is not the subject of this analysis. One the other hand there are some factors that decrease air pollution. For example it is well-known fact that strong wind blows away smog from the city. In this analysis I will try to find some predictors for smog levels. As I have full weather data and no data about traffic or coal-heating, I will make some assumptions. Temperature is probably highly correlated with heating usage, so I will assume that, it's a good substitution. There is a bigger problem with traffic, but I will take a closer look at smog level in rush hours and days of week.
Finally I want to answer the title question: as we can predict weather, can we also predict smog? Only on the basis of weather forecast. Probably accuracy of obtained model won't be the best (as if it was so simple everyone would do it), but maybe somebody could find it useful.

## Data sources

Analysis was performed on the basis on smog data (measured as PM10 concentration) and historical weather data in the period from January 1, 2015 to March 15, 2018. Smog data are powered by <a href="http://powietrze.gios.gov.pl" title="Chief Inspectorate For Environmental Protection"> Polish Chief Inspectorate For Environmental Protection</a>. 
Weather data are powered by <a href="https://developer.worldweatheronline.com/" title="Free Weather API" target="_blank">World Weather Online</a>. All data were available in 1-hour interval.
Whole analysis was performed for one measured station located in Krasiński Street, Cracow, Poland. I believe that general ideas from this analysis could be applied into other locations, but detailed results may varies.
Available weather data included:
* Temperature (&deg;C)
* Wind speed (kmph)
* Humidity (%)
* Pressure (milibars)
* Precipitation (mm)
* Feels like temperature (&deg;C)
* Cloud cover amount (%)
* Wind direction (degrees)

## Data exploration

## PM10 modelling

## Air pollution modelling

## What's next?

- [x] Download data  
- [ ] Data exploration  
- [ ] PM10 gam modelling  
- [ ] Air pollution level gam modelling  
- [ ] More advanced modelling (random forest?)  

