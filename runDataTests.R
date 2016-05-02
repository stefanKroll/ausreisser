options(browser='C:/Program Files/Mozilla Firefox/firefox.exe')

libDir = 'C:/user1580/Projects/HSG/R/lib'#library location on disk
scriptDir = 'C:/user1580/Projects/HSG/R/scripts'#location of this set of scripts
dataDir = 'C:/user1580/Projects/HSG/R/data'#input data location, will be used as parent location for output data (graphs)

wannaUseNewLib <- TRUE# old or new m181 code
wannaUseSavitzkyGolay <- TRUE# savitzky golay or m181
wannaPlot <- TRUE

#file name of input data
#fileToRead<-'data_meerhout_CSO_turbidity.rds'
#fileToRead<-'data_meerhout_pump_conductivity.rds'
fileToRead<-'data_broekelei_pump_turbidity.rds'

source(paste(scriptDir,'/useLibraries.R', sep = ''))
source(paste(scriptDir,'/sensTestOutlier.R', sep = ''))
source(paste(scriptDir,'/plot2html.R', sep = ''))



ts<-readRDS(paste(dataDir, '/', fileToRead, sep = ''))

ts<-xts::first(ts, n=1440)
#ts<-xts::last(ts, n=200)

if (wannaUseSavitzkyGolay){
  dataDir<-paste(dataDir,'/savGol', sep = '')
}else{
  dataDir<-paste(dataDir,'/movAvg', sep = '')
}

dir.create(dataDir, showWarnings = FALSE)
setwd(dataDir);


if (wannaPlot){
  graph <- dygraph(ts) %>%  dyRangeSelector()
  #print(graph)
  #plotcommand = 'dygraph(ts) %>% dyRangeSelector()'
  fileName<-plot2html(graph, plotName='timeseries2')
}

distanceCritSeq <- c(seq(0.1,1,0.1),2,3)
widthSeq <- c(2,4,6,8,seq(10,100,10))

if (wannaUseSavitzkyGolay){
  distanceCritSeq <- c(seq(0.1,1,0.1))*100#savitzky golay: abs(distance smoothened - raw)
  widthSeq<- c(2,4,6,8,seq(10,50,10))+3#savitzky golay needs odd filter length
  #distanceCritSeq <- 50
  #widthSeq<- c(5, 7)
}

#sens.test <- sens.test.outlier(ts = ts, distanceCritSeq, moving.average = TRUE, width = widthSeq)
runTime<-system.time(sens.test <- sens.test.outlier(ts = ts, distanceCritSeq, moving.average = TRUE, width = widthSeq))

# plot sensitivities:
plot(sens.test[,1],sens.test[,3], las = 1, type = "o", pch = 16, xlab = names(sens.test)[1], ylab = names(sens.test)[3], cex.axis = 1.2, cex.lab = 1.2)
plot(sens.test[,2],sens.test[,3], las = 1, type = "o", pch = 16, xlab = names(sens.test)[2], ylab = names(sens.test)[3], cex.axis = 1.2, cex.lab = 1.2)
sens <- matrix(sens.test[, 3], nrow = length(widthSeq), byrow = FALSE)
hist3D(widthSeq, distanceCritSeq, sens, xlab='width', ylab='distance', zlab='% true values',  ticktype = "detailed")
print(runTime)
