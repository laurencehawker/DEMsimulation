#Read Ba CCI and export to Data

library(raster)
Ba_CCI <- raster('data-raw/Ba_CCI.tif')
devtools::use_data(Ba_CCI,overwrite = TRUE)
