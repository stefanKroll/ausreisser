sens.test.outlier <- function(ts, distanceCritSeq, moving.average, widthSeq = 5, varName = 'data') {
  
  if (wannaUseSavitzkyGolay){
    print("Savitzky Golay")
  }
    else{
    print("m181")
    }
  
  time(ts) <- round(time(ts), "mins")
  
  tsAsDataFrame <- t(as.data.frame(ts))
  #do same conversion for ts as for smoothTs because of accuracy issues in date column of xts(!!??):
  tmpTsAsDataFrame <- t(tsAsDataFrame)
  reconvertedTs <- xts(tmpTsAsDataFrame,as.POSIXct(rownames(tmpTsAsDataFrame), tz = "GMT", origin = "1970-1-1"))
  names(reconvertedTs) <- 'ts'
  #reconvertedTs <- ts
  
  sens.test <- NULL
  for (distanceCrit in distanceCritSeq) {
    for (width in widthSeq) {
      plotName <- paste(" distanceCrit ", distanceCrit, " width ", width, collapse = "")
      print(paste("Waiting for results for ", plotName, " ...", collapse = ""))
      perc.true.values <- NaN
      if (wannaUseSavitzkyGolay){
        smoothTsAsDataFrame <- t(savitzkyGolay(tsAsDataFrame, p=7, w=width, m=0))
        smoothTs<-xts(smoothTsAsDataFrame,as.POSIXct(rownames(smoothTsAsDataFrame), tz = "GMT", origin = "1970-1-1"))
        names(smoothTs) <- 'smoothTs'

        #align time (savitzkyGolay cuts the first elements) by adding dummy data:
        tmpIndex <- 1:((width-1)/2)
        dummyData <- reconvertedTs[tmpIndex, ]
        dummyData[ ,1] <- NA
        smoothTs <- rbind(smoothTs, dummyData)
        
        
        #see m181 code:
        flag <- which(abs(reconvertedTs - smoothTs) > distanceCrit)

        my.outlier <- reconvertedTs
        mode(my.outlier) <- "logical";
        if (identical(flag, integer(0))) {
          zoo::coredata(my.outlier)[, ] <- TRUE
        }
        else {
          my.outlier[flag] <- FALSE
          my.outlier[-flag] <- TRUE
        }
		
      }
      else{
      if (wannaUseNewLib){
        my.outlier <- check_outlier(ts,sigma_multiplier = distanceCrit, moving_window = moving.average, width = width, type="mean")
      }
        else{
        my.outlier <- outlier(ts,sigma.multiplier = distanceCrit, moving.average = moving.average, width = width)
        }
      }
      
      
      n.true.values <- length(ts[my.outlier])
      n.all.values <- length(ts)
      perc.true.values <- n.true.values/n.all.values*100
      sens.test.new <- c(distanceCrit, width, perc.true.values)
      sens.test <- rbind(sens.test, sens.test.new)

      my.outlier <- ts[!my.outlier];
      
      if ((length(my.outlier) > 0) & wannaPlot) {
        names(my.outlier) <- 'my.outlier'
        if (wannaUseSavitzkyGolay){
          plotData <- merge(ts, my.outlier, smoothTs);
          
          tmpGraph <- dygraph(plotData, xlab = "Time", ylab = plotName, height=800, width=1200, main=paste(plotName, '   --> true values ', perc.true.values, ' %', sep="")) %>% dySeries("ts", color = "black") %>% dySeries("my.outlier", drawPoints = TRUE, pointSize = 3, color = "yellow", strokeWidth = 0) %>% dySeries("smoothTs", color = "blue")  %>%  dyRangeSelector()
        }
        else{
          plotData <- merge(ts, my.outlier)
          tmpGraph <- dygraph(plotData, xlab = "Time", ylab = plotName, height=800, width=1200, main=paste(plotName, '   --> true values ', perc.true.values, ' %', sep="")) %>% dySeries("ts", color = "black") %>% dySeries("my.outlier", drawPoints = TRUE, pointSize = 3, color = "yellow", strokeWidth = 0)  %>%  dyRangeSelector()
          
        }
       
        # plot
        #plot2html(plotCommand, plotName = plotName, plotData=plotData, varName=varName)
        #plot2html(plotCommand, plotName = plotName, plotData=plotData, varName=varName
        
        fileName<-plot2html(tmpGraph, plotName=plotName)
        #visualise_dy(ts, my.outlier)
      }
    }
  }
  sens.test <- data.frame(sens.test,row.names = NULL)
  names(sens.test) <- c("distanceCrit", "width", "true values (%)")
  cat("\n",paste("Summary of results:", collapse = "\n"),rep("\n",2))
  print(sens.test)
}