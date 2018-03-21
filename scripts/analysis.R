# data handle
library(dplyr)
# plots
library(ggplot2)
# gam models
library(mgcv)

# load all data
source('scripts/load_data.R')


# lets see PM10 distribution

ggplot(dfAllData,aes(PM10), geom = 'blank') +
  geom_histogram(aes(y = ..density..),bins = 30, color = 'white', fill = 'black', alpha = 0.4) +
  geom_line(aes(y = ..density.., colour = 'Empirical'), stat = 'density') +
  stat_function(fun = dnorm, args = list(mean = mean(dfAllData$PM10), sd = sd(dfAllData$PM10)), aes(colour = 'Normal')) +
  scale_colour_manual(name = 'Density', values = c('red', 'blue')) + 
  theme(legend.position = c(0.85, 0.85)) +
  xlim(0,400) +
  labs(
    x = expression(paste('PM10 ',mu,'g/m'^3)),
    y = 'Density'
  ) +
  theme_classic() +
  theme(
    legend.position="bottom",
    legend.box = "horizontal",
    axis.text.x = element_text(
      angle = 45, 
      vjust = 1, 
      hjust=1
    )
  ) -> FullDist
  

# saving plot
ggsave(
  filename = 'plots/FullDist.png',
  plot = FullDist,
  width = 8,
  dpi = 100
)

# log distribution
ggplot(dfAllData,aes(logPM10), geom = 'blank') +
  geom_histogram(aes(y = ..density..),bins = 30, color = 'white', fill = 'black', alpha = 0.4) +
  geom_line(aes(y = ..density.., colour = 'Empirical'), stat = 'density') +
  stat_function(fun = dnorm, args = list(mean = mean(dfAllData$logPM10), sd = sd(dfAllData$logPM10)), aes(colour = 'Normal')) +
  scale_colour_manual(name = 'Density', values = c('red', 'blue')) + 
  theme(legend.position = c(0.85, 0.85)) +
  labs(
    x = expression(paste('log PM10 ',mu,'g/m'^3)),
    y = 'Density'
  ) +
  theme_classic() +
  theme(
    legend.position="bottom",
    legend.box = "horizontal",
    axis.text.x = element_text(
      angle = 45, 
      vjust = 1, 
      hjust=1
    )
  ) -> FullLogDist


# saving plot
ggsave(
  filename = 'plots/FullLogDist.png',
  plot = FullLogDist,
  width = 8,
  dpi = 100
)

# for a start let's see log PM10 over months
ggplot(dfAllData) +
  geom_jitter(
    aes(
      x = day,
      y = logPM10, 
      fill = AirQuality
    ),
    pch = 21
  )  +
  scale_fill_brewer(
    palette = 'RdYlGn',
    direction = -1
  ) +
  scale_x_continuous(
    breaks = c(1,5,10,15,20,25,30)
  ) +
  labs(
    x = 'Days' ,
    y  = expression(paste('log PM10 ',mu,'g/m'^3))
    fill = 'Air quality'
  ) + 
  facet_wrap(
    facets = ~ month, 
    nrow = 2, 
    ncol = 6
  ) +
  theme_classic() +
  theme(
    legend.position="bottom",
    legend.box = "horizontal",
    axis.text.x = element_text(
      angle = 45, 
      vjust = 1, 
      hjust=1
    )
  ) -> FullMonthly

# saving plot
ggsave(
  filename = 'plots/FullMonthly.png',
  plot = FullMonthly,
  width = 8,
  dpi = 100
  )

# filter month with smog
dfAllData %>% 
  filter(month %in% c(1,2,3,4,10,11,12)) ->
  dfWinterData

glimpse(dfWinterData)

dfWinterData %>%
  mutate(IfPrecipitation = precipMM>0) ->
  dfWinterData

# lets see PM10 distribution on new data

ggplot(dfWinterData,aes(logPM10), geom = 'blank') +
  geom_histogram(aes(y = ..density..),bins = 30, color = 'white', fill = 'black', alpha = 0.4) +
  geom_line(aes(y = ..density.., colour = 'Empirical'), stat = 'density') +
  stat_function(fun = dnorm, args = list(mean = mean(dfWinterData$logPM10), sd = sd(dfWinterData$logPM10)), aes(colour = 'Normal')) +
  scale_colour_manual(name = 'Density', values = c('red', 'blue')) + 
  theme(legend.position = c(0.85, 0.85)) +
  labs(
    x = expression(paste('log PM10 ',mu,'g/m'^3)),
    y = 'Density'
  ) +
  theme_classic() +
  theme(
    legend.position="bottom",
    legend.box = "horizontal",
    axis.text.x = element_text(
      angle = 45, 
      vjust = 1, 
      hjust=1
    )
  )  -> WinterDist

# let's see log PM10 over weekdays
ggplot(
  dfWinterData,
  aes(
    x = as.factor(weekday),
    y = logPM10,
    colour = as.factor(weekday),
    fill = as.factor(weekday)
  )
) +
  scale_fill_discrete(name = "", labels = c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')) +
  scale_colour_discrete(name = "", labels = c('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')) +
  # data
  geom_boxplot() +
  theme_classic() +
  theme(
    axis.text.x=element_blank(),
    legend.position="bottom",
    legend.box = "horizontal"
  ) +
  labs(
    x = 'Weekday',
    y = expression(paste('log PM10 ',mu,'g/m'^3))
  ) +
  stat_summary(
    geom = "crossbar",
    width=0.65, 
    fatten=0, 
    color="white", 
    fun.data = function(x){ return(c(y=median(x), ymin=median(x), ymax=median(x))) }
  ) +
  stat_summary(
    fun.data = function(x){ return(c(y=median(x),label = round(median(x),1)))}, 
    geom="text", 
    vjust=-0.8,
    color = 'white'
  ) -> WeekdayDist

# saving plot
ggsave(
  filename = 'plots/WeekdayDist.png',
  plot = WeekdayDist,
  width = 8,
  dpi = 100
)

# let's see log PM10 over hours
ggplot(dfAllData) +
  geom_jitter(
    aes(
      x = time,
      y = logPM10, 
      fill = AirQuality
    ),
    pch = 21
  )  +
  geom_smooth(
    aes(
      x = time,
      y = logPM10
    )
  ) +
  scale_fill_brewer(
    palette = 'RdYlGn',
    direction = -1
  ) +
  labs(
    x = 'Days' ,
    y  = expression(paste('log PM10 ',mu,'g/m'^3)),
    fill = 'Air quality'
  ) + 
  theme_classic() +
  theme(
    legend.position="bottom",
    legend.box = "horizontal",
    axis.text.x = element_text(
      angle = 45, 
      vjust = 1, 
      hjust=1
    )
  ) -> HoursDist

# saving plot
ggsave(
  filename = 'plots/HoursDist.png',
  plot = HoursDist,
  width = 8,
  dpi = 100
)

#######################################
##  loop for plot of every variable
#######################################

iUnits <- list(
  tempC = 'Temperature [°C]',
  FeelsLikeC = 'Feels like temperature [°C]',
  windspeedKmph = 'Wind speed [km/h]',
  winddirDegree = 'Wind direction [degrees]',
  humidity = 'Humidity [%]',
  pressure = 'Pressure [millibars]',
  cloudcover = 'Cloudiness [%]',
  precipMM = 'Precipitation [mm]'
)

for (iWeatherVariable in names(iUnits)) {
  
  # glm formula 
  as.formula(
    paste0(
      'logPM10 ~',
      iWeatherVariable
    )
  ) -> 
    sFormulaGlm
  
  # linear model
  glm(
    formula = sFormulaGlm,
    data = dfWinterData
  ) ->
    mGlmFit
  
  # smooth spline degrees of freedom
  smooth.spline(
    x = dfWinterData$PM10,
    y = dfWinterData[[iWeatherVariable]],
    cv = TRUE
  ) -> 
    mSmoothFit
  
  # gam formula
  as.formula(
    paste0(
      'logPM10 ~ s(',
      iWeatherVariable,
      ', k = ',
      mSmoothFit$df,
      ')'
    )
  ) -> 
    sFormulaGam
  
  # smooth splines model
  gam(
    formula = sFormulaGam,
    data = dfWinterData,
    family = gaussian
  ) ->
    mGamFit
  
  # variable grid
  range(dfWinterData[[iWeatherVariable]]) -> cRange
  dfGrid <- data.frame(seq(cRange[1],cRange[2], by = (cRange[2] - cRange[1])/500))
  names(dfGrid) <- iWeatherVariable
  
  # preadict on grid
  predict(mGlmFit, newdata = dfGrid, se.fit = TRUE) -> mGlmPredict
  predict(mGamFit, newdata = dfGrid, se.fit = TRUE) -> mGamPredict
  
  # cutting at 0 for plot
  mGlmPredict$fit -> dfGrid$glm
  sapply(mGlmPredict$fit - 2 * mGlmPredict$se.fit, max, 0) -> dfGrid$glmCIL
  sapply(mGlmPredict$fit + 2 * mGlmPredict$se.fit, max, 0) -> dfGrid$glmCIU
  mGamPredict$fit -> dfGrid$gam
  sapply(mGamPredict$fit - 2 * mGamPredict$se.fit, max, 0) -> dfGrid$gamCIL
  sapply(mGamPredict$fit + 2 * mGamPredict$se.fit, max, 0) -> dfGrid$gamCIU
  
  ggplot(dfWinterData) +
    # data
    geom_jitter( 
      aes_string(iWeatherVariable,'logPM10', fill = 'AirQuality'),
      pch = 21
    )  +
   # linear model
    geom_line(
      aes_string(
        iWeatherVariable, 
        'glm', 
        colour = "'linear model'"
      ), 
      data = dfGrid, 
      size = 1, 
      linetype = 1
    ) + 
    # confidence interval 
    geom_ribbon(
      aes_string(
        x = iWeatherVariable,
        ymin = 'glmCIL',
        ymax = 'glmCIU'
      ),
      data = dfGrid, 
      alpha = 0.3
    ) +
    # gam model
    geom_line(
      aes_string(
        iWeatherVariable, 
        'gam', 
        colour = "'smooth spline model'"
      ),
      data = dfGrid, 
      size = 1, 
      linetype = 1
    ) + 
    # confidence interval 
    geom_ribbon(
      aes_string(
        x = iWeatherVariable,
        ymin = 'gamCIL',
        ymax = 'gamCIU'
      ),
      data = dfGrid, 
      alpha = 0.3
    ) +
    scale_color_discrete(name = "") +
    scale_fill_brewer( 
      palette = 'RdYlGn',
      direction = -1,
      name = "Air quality"
    ) +
     labs(
      x = iUnits[[iWeatherVariable]],
      y = expression(paste('log PM10 ',mu,'g/m'^3))
    ) +
    theme_classic() +
    theme(
      legend.position="bottom",
      legend.box = "horizontal",
      axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)
    ) -> ggPlot
  
  ggsave(
    filename = paste0('plots/',iWeatherVariable,'.png'),
    plot = ggPlot,
    width = 8,
    dpi = 100
  )
  
}

# humidity over temperature plot

ggplot(dfWinterData) +
  # data
  geom_jitter( 
    aes(
      x = humidity,
      y = tempC,
      fill = AirQuality
    ),
    pch = 21
  )  +
  scale_fill_brewer(
    palette = 'RdYlGn',
    direction = -1
  ) +
  geom_smooth(
    aes(x = humidity, y = tempC)) +
  # linear model
  labs(
    x = iUnits[['humidity']],
    y = iUnits[['tempC']]
  ) +
  theme_classic() +
  theme(
    legend.position="bottom",
    legend.box = "horizontal",
    axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)
  ) -> ggPlot
  
ggsave(
    filename = paste0('plots/HumTemp.png'),
    plot = ggPlot,
    width = 8,
    dpi = 100
  )

# boolean precipitation plot

ggplot(
  dfWinterData,
  aes(
    x = IfPrecipitation,
    y = logPM10,
    colour = IfPrecipitation,
    fill = IfPrecipitation
  )
) +
  scale_fill_discrete(name = "", labels = c('Precipitation','No precipitation')) +
  scale_colour_discrete(name = "", labels = c('Precipitation','No precipitation')) +
  # data
  geom_boxplot() +
   theme_classic() +
  theme(
    axis.text.x=element_blank(),
    legend.position="bottom",
    legend.box = "horizontal"
    ) +
  labs(
    x = '',
    y = expression(paste('log PM10 ',mu,'g/m'^3))
  ) +
  stat_summary(
    geom = "crossbar",
    width=0.65, 
    fatten=0, 
    color="white", 
    fun.data = function(x){ return(c(y=median(x), ymin=median(x), ymax=median(x))) }
  ) -> ggPlot

ggsave(
  filename = paste0('plots/IfPrecip.png'),
  plot = ggPlot,
  width = 8,
  dpi = 100
)

# winder direction and speed plot

ggplot(dfWinterData) +
  # data
  geom_jitter( 
    aes(
      x = winddirDegree,
      y = windspeedKmph,
      fill = AirQuality
    ),
    pch = 21
  )  +
  scale_fill_brewer(
    palette = 'RdYlGn',
    direction = -1
  ) +
  geom_smooth(
    aes(x = winddirDegree, y = windspeedKmph)) +
  # linear model
  labs(
    x = iUnits[['winddirDegree']],
    y = iUnits[['windspeedKmph']]
  ) +
  theme_classic() +
  theme(
    legend.position="bottom",
    legend.box = "horizontal",
    axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)
  ) -> ggPlot

ggsave(
  filename = paste0('plots/WindSpeedDegree.png'),
  plot = ggPlot,
  width = 8,
  dpi = 100
)
