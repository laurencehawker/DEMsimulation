#' Read in semi-variogram for simulation
#'
#'\code{modelselect} Select Semi-Variogram for DEM Simulation
#'
#' @param model semi-variogram model to use in simulation
#' Choose from one of 'Burdekin', 'Ebro', 'Fens DSM', Fens DTM','Mekong','Mississippi','Po Delta'
#' or 'Wax lake'.
#' @return Semi-variogram Model
#' @export
modelselect <- function(model = "") {
    data("MERIT_semi_variograms_NoNugget_Threshold90")  #Reads data
    svname <- paste(names(robj1), collapse = "   ")  #Creates list of available semi-variograms
    if (missing(model))
        model = "Mekong"  #Sets default if missing
    modelselect2 <- robj1[[model]]["vgm_sum_fit"]  #Reads model name
    if (is.null(modelselect2))
        stop(paste0("Not a semi-variogram. Use one of ", svname))  #If invalid semi-variogram entered displays a warning and diplsays available semi-variograms
    return(modelselect2)
}



# #Model #' @export model <- function(vgm_delta) { data('fitted0') if(missing(vgm_delta))
# vgm_delta='Mekong' #sets default to Mekong #vgm_delta <- 'Mekong' #Name of delta semivariogram to use
# #vgm_delta <- readline(prompt = 'Enter Delta name: ') # User interaction vgm_sum_fit <-
# Fitted0[[vgm_delta]][c('vgm_sum_fit')] #Model to dataframe model <- vgm_sum_fit[['vgm_sum_fit']]
# devtools::use_data(model, overwrite = TRUE) } #this needs a lot of work. Do I just load all the
# semi-variograms as rda files or model <- function(vgm_delta) {
# data('MERIT_semi_variograms_NoNugget_Threshold90') #if(missing(vgm_delta)) vgm_delta='Mekong' #sets
# default to Mekong #vgm_delta <- 'Mekong' #Name of delta semivariogram to use #vgm_delta <-
# readline(prompt = 'Enter Delta name: ') # User interaction # vgm_sum_fit <-
# Fitted0[[vgm_delta]][c('vgm_sum_fit')] #Model to dataframe # model <- vgm_sum_fit[['vgm_sum_fit']]
# devtools::use_data(model, overwrite = TRUE) #this saves model to be used elsewhere } model <- 'Mekong'
# svname <- model
