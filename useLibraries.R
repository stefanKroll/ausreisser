if (wannaUseNewLib){
  install.packages(paste(libDir,'/m181_0.3.4.zip', sep = ''), repos = NULL, type = "win.binary")
}  else   {
  install.packages(paste(libDir, '/m181_0.2.3.tar', sep = ''), repos = NULL, type = "source")
  #install.packages(paste(libDir, '/m181_0.04.zip', sep = ''), repos = NULL, type = "win.binary")
}


require("dygraphs")
require("ggplot2")
require("lattice")
require("xts")
require("RcppArmadillo")#c code integration
#library("R.matlab")

require("m181")
require("prospectr")#savitzky golay

require("scatterplot3d")
require("plot3D")
require("rbenchmark")



