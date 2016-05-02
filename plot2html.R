#Parameters:
#    graph: een dygraphs, plotly of ggplot2 object dat bij invoer in de commandolijn een plot zal maken
#    plotName: bestandsnaam zonder .html
#    breedte: breedte figuur in inch (standaard 12 inch)
#    hoogte: hoogte figuur in inch (standaard 8 inch)
plot2html<-function(graph, plotName='plot', breedte=12, hoogte=8) {
  
  write(paste0( "```{r, fig.width=", breedte, ", fig.height=", hoogte, ",echo=FALSE}\ngraph\n```", sep = ""), file = paste(plotName , ".Rmd", sep = ""))
  returnFileName<-rmarkdown::render(paste(plotName , ".Rmd", sep = ""))
  returnFileName<-gsub('/','\\\\', returnFileName)
  file.remove(paste(plotName , ".Rmd", sep = ""))
  }