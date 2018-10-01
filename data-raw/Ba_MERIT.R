#Read Ba tif and export to Data

library(raster)
Ba_MERIT <- raster('data-raw/Ba_MERIT_Z.tif')
devtools::use_data(Ba_MERIT,overwrite = TRUE)
