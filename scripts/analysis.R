# data handle
library(dplyr)
# plots
library(ggplot2)
# gam models
library(mgcv)

# load all data
source('scripts/load_data.R')


# lets see PM10 distribution

ggplot(dfAllData,aes(PM10, ..density..)) +
  geom_histogram(bins = 100, color = 'white', fill = 'black', alpha = 0.6) +  
  xlim(0,400) +
  labs(
    x = expression(paste('PM10 ',mu,'g/m'^3)),
    y = 'Density',
    fill = 'Year'
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

# for a start let's see PM10 over months

ggplot(dfAllData) +
  geom_jitter(
    aes(
      x = day,
      y = PM10, 
      color = AirQuality, 
      shape = as.factor(year)
    )
  )  +
  scale_colour_brewer(
    palette = 'RdYlGn',
    direction = -1
  ) +
  scale_x_continuous(
    breaks = c(1,5,10,15,20,25,30)
  ) +
  labs(
    x = 'Days' ,
    y  = expression(paste('PM10 ',mu,'g/m'^3)),
    shape = 'Year',
    color = 'Air quality'
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

ggplot(dfWinterData,aes(PM10, ..density..)) +
  geom_histogram(bins = 100, color = 'white', fill = 'black', alpha = 0.6) +  
  xlim(0,400) +
  labs(
    x = expression(paste('PM10 ',mu,'g/m'^3)),
    y = 'Density',
    fill = 'Year'
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
  ) -> WinterDist


# saving plot
ggsave(
  filename = 'plots/WinterDist.png',
  plot = WinterDist,
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
  cloudcover = 'Cloud cover amount [%]',
  precipMM = 'Precipitation [mm]'
)

for (iWeatherVariable in names(dfWinterData)[c(3:10)]) {
  
  # glm formula 
  as.formula(
    paste0(
      'PM10 ~',
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
      'PM10 ~ s(',
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
      aes_string(iWeatherVariable,'PM10'), 
      color = 'black', 
      size = 0.5
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
    ylim(0,400) + 
    labs(
      x = iUnits[[iWeatherVariable]],
      y = expression(paste('PM10 ',mu,'g/m'^3))
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
      color = AirQuality),
    size = 0.95
  )  +
  scale_colour_brewer(
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
    y = PM10,
    colour = IfPrecipitation,
    fill = IfPrecipitation
  )
) +
  scale_fill_discrete(name = "", labels = c('Precipitation','No precipitation')) +
  scale_colour_discrete(name = "", labels = c('Precipitation','No precipitation')) +
  # data
  geom_boxplot() +
  ylim(0,400) +
  theme_classic() +
  theme(
    axis.text.x=element_blank(),
    legend.position="bottom",
    legend.box = "horizontal"
    ) +
  labs(
    x = '',
    y = expression(paste('PM10 ',mu,'g/m'^3))
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
      color = AirQuality),
    size = 0.95
  )  +
  scale_colour_brewer(
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
