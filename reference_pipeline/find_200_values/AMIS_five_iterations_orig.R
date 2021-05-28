###############################################
# Projections using transmission model and geostatistical map of Trachoma
#
#  Using algorithm written by Retkute et al. 2020
#  "Integrating geostatistical maps and transmission models using
# multiple impotance sampling
#  Modified by SPatel
#  Adapted by PTouloupou: trachoma model
### NOTES: using IUs instead of pixels
###
### Requires: Maps file, python code with parameter file, AMIS source
###############################################

iscen = 1
rm(list=setdiff(ls(), "iscen"))

# library(tmvtnorm)
library(mnormt)
library(mclust)
library(reticulate)

Data = read.csv("./data/FinalDataPrev.csv")
DataScenarios = data.frame(Data$start_MDA, Data$last_MDA, Data$Scenario, Data$Group)
DataScenarios = unique(DataScenarios)
DataScenarios = DataScenarios[-which(DataScenarios$Data.Group == 7), ]

Scen = DataScenarios$Data.Scenario
start_MDA = DataScenarios$Data.start_MDA
last_MDA = DataScenarios$Data.last_MDA
Group = DataScenarios$Data.Group

prefix <- sprintf("scen%g_group%g", Scen[iscen], Group[iscen])
folder <- "output/"  # which folder to save final files to

IU_scen <- which(Data$Scenario == Scen[iscen] & Data$Group == Group[iscen])
IU_scen_name <- Data$IUCodes[IU_scen] # indicates which IUs to usescen3

use_virtualenv("./.venv", required=TRUE)

source("AMIS_source.R")  # source code for AMIS
transmission_model <- import("trachoma")

# function to draw from prior
dprop0<-function(a,b){
  return(dunif(a, min=0.05, max=0.175)*dunif(b, min=0, max=1))
}
rprop0<-function(n){
  return(list(runif(n, min=0.05, max=0.175), runif(n, min=0, max=1)))
}

############## AMIS and MAP parameters ############
n.pixels<-length(IU_scen)  # Number of pixels OR IUs
n.map.sampl<-3000 # Number of samples for the map
ESS.R<-250 # Desired effective sample
delta<-5 # delta value (width for the Radon-Nikodym derivative) %
n.param<-2

T<-5; # max number of iterations
NN<-100  # Number of parameter sets in each iteration
N<-rep(NN,T)  # This allows to have different number of parameters sampled each iteration. Here it's the same  # different number of iterations might break code
#N[1] <- 50

############# Geostatistical prevalences ########
prev <- matrix(
    scan(file = "prevalence_map.csv"),
    nrow = length(IU_scen), byrow = T
)
mean.prev<-sapply(1:n.pixels, function(a) mean(prev[a,]))

###################################################################
#          AMIS setup
####################################################################
# Set distribution for proposal: Student's t distribution
proposal=mvtComp(df=3); mixture=mclustMix();
dprop <- proposal$d
rprop <- proposal$r

# Set prior distribution:
#d <- read.csv(prior_file)   # raw data for making prior
# random sample and density functions in Ascaris_prior file

param<-matrix(NA, ncol=n.param+1+1, nrow=sum(N))  # Matrix for parameter values, + prevalence and weights
Sigma <- list(NA, 10*T)
Mean<-list(NA, 10*T)
PP<-list(NA,T)
GG<-list(NA,T)

set.seed(1)
###################################################################
#          Iteration 1.
####################################################################
t<-1  # Iteration
tmp<-rprop0(N[t])    #N[t] random draws of parameters from prior
x <- tmp[[1]]  # bet
y <- tmp[[2]]  # constant
seed <- c(1:N[t])
allseed <- seed
input_params <- cbind(seed, x)
colnames(input_params) = c("randomgen", "bet")

inputbeta <- sprintf("files/InputBet_scen%g_group%g_it%g.csv", Scen[iscen], Group[iscen], t)
write.csv(input_params, file=inputbeta, row.names=FALSE)

print(Sys.time())
### Run Python
# output R0, k file with seed to be input for python
#STH_Simulation(paramFileName='AscarisParameters_moderate.txt', demogName='WHOGeneric', MDAFilePath='files/Input_MDA_23Oct20.csv', PrevFilePath='files/OutputPrev_STH_test.csv', RkFilePath='files/InputRk_STH.csv', nYears=18, outputFrequency=1, numReps=as.integer(3), SaveOutput=FALSE)  # only works for 3 at a time on my laptop- problems with multiprocessing

inputMDA <- sprintf("files/InputMDA_scen%g.csv", Scen[iscen], Group[iscen])
infect_output <- sprintf("output/InfectFilePath_scen%g_group%g.csv", Scen[iscen], Group[iscen])
prevalence_output <- sprintf("output/OutputPrev_scen%g_group%g_it%g.csv", Scen[iscen], Group[iscen], t)
transmission_model$Trachoma_Simulation(inputbeta,
                                       inputMDA,
                                       prevalence_output,
                                       infect_output,
                                       SaveOutput=FALSE,
                                       OutSimFilePath=NULL,
                                       InSimFilePath=NULL)
###
print(Sys.time())

# read in python output file
res <- read.csv(prevalence_output)
ans <- 100*res[,dim(res)[2]]

w<-sapply(1:length(ans), function(i) length(which((prev>ans[i]-delta/2) &(prev<=ans[i]+delta/2)))/length(which((ans>ans[i]-delta/2) & (ans<=ans[i]+delta/2))))   #weights over all IUs

param[1:N[1],1]<-x
param[1:N[1],2]<-y
param[1:N[1],3]<-ans
param[1:N[1],4]<- w

prop<-param[1:N[1],]

# Calculate effective sample size
ess<-c()
WW<-matrix(NA, nrow=n.pixels, ncol=sum(N[1]))
for(i in 1:n.pixels){
  w<-sapply(1:length(ans), function(j) length(which((prev[i,]>ans[j]-delta/2) &(prev[i,]<=ans[j]+delta/2)))/length(which((ans>ans[j]-delta/2) & (ans<=ans[j]+delta/2))))   # don't need to weight g because first iteration
  #ww<-w/(prop.val);   # SP: don't understand this step
  ww<-w
  if(sum(ww)>0){
    ww<-ww/sum(ww)
  }
  WW[i,]<-ww
  if( sum(ww)==0){
    www<-0
  } else {
    www<-(sum((ww)^2))^(-1)
  }
  ess<-c(ess, www)
  #cat(c(t, "", i,"", www,"\n"))
}


cat( min(ess),  "", max(ess), "\n")

ESS<-matrix(ess, nrow=1, ncol=n.pixels)
filename <- sprintf("tests/test_data/ESS_iteration_%g.csv", t)
write.table(ESS, file=filename, row.names = F, col.names = F)

filename <- sprintf("tests/test_data/param_iteration_%g.csv", t)
allseeds <- 1:sum(N[1:(t)])
ret <- data.frame(allseeds, param[1:sum(N[1:(t)]),c(1,3)], t(WW))
colnames(ret) <- c(
    "seeds", "beta", "sim_prev",
    sapply(1:dim(WW)[1], function(idx) sprintf("iu%g", idx))
)
write.csv(file = filename, ret, row.names = F)

#pdf(file=paste0(folder, "plot.",prefix,"_",  t, ".pdf"))
#pp<-data.frame(x=param[1:sum(N[1:(t)]),1],  prevalence=param[1:sum(N[1:(t)]),2])
#pp<-pp[order(pp$prevalence),]
#f2<- ggplot(pp, aes(prevalence)) + geom_histogram()
#xx<-data.frame(mean.prevalence=mean.prev, ESS=ESS[nrow(ESS),])
#f3<-qplot(mean.prevalence, ESS, data = xx)
#grid.arrange(f2, f3, ncol=3, widths=c(1.25,1,1))
#dev.off()

###################################################################
#          Iteration 2+
####################################################################

stop<-0
while(stop==0){
  
  t<-t+1
  cat(c("Iteration: ", t,", min(ESS): ", min(ess),"\n"))
  
  wh<-which(ess>=ESS.R)
  W1<-WW; W1[wh,]<-0
  
  w1<- c(colSums(W1))
  
  
  J<-sample(1:sum(N[1:(t-1)]), NN, prob= w1, replace=T)
  xx<-param[J,1:2]
  clustMix <- mixture(xx)
  
  G <- clustMix$G
  cluster <- clustMix$cluster
  
  ### Components of the mixture
  ppt <- clustMix$alpha
  muHatt <- clustMix$muHat
  varHatt <- clustMix$SigmaHat
  GG[[t-1]]<-G
  G1<-0; G2<-G
  if(t>2) {
    G1<-sum(sapply(1:(t-2), function(a) GG[[a]]))
    G2<-sum(sapply(1:(t-1), function(a) GG[[a]]))
  }
  for(i in 1:G){
    Sigma[[i+G1]] <- varHatt[,,i]
    Mean[[i+G1]] <- muHatt[i,]
    PP[[i+G1]]<-ppt[i]   ### scale by number of points
  }
  
  ### Sample new from the mixture...
  ans<-c(); x<-c(); y<-c()
  print("start sampling")
  print(Sys.time())
  while(length(x)<N[t]){
    compo <- sample(1:G,1,prob=ppt)
    x1 <- t(rprop(1,muHatt[compo,], varHatt[,,compo]))
    new.param<-as.numeric(x1)
    if(dprop0(new.param[1],new.param[2])>0){
      x<-c(x, new.param[1])
      y<-c(y, new.param[2])
    }
    i<-i+1
  }
  print("done sampling")
  print(Sys.time())
  
  seed <- c((max(seed)+1): (max(seed)+N[t]))
  allseed <- c(allseed, seed)
  input_params <- cbind(seed, x)
  colnames(input_params) = c("randomgen", "bet")

    inputbeta <- sprintf("files/InputBet_scen%g_group%g_it%g.csv", Scen[iscen], Group[iscen], t)  
    write.csv(input_params, file=inputbeta, row.names=FALSE)

    prevalence_output <- sprintf("output/OutputPrev_scen%g_group%g_it%g.csv", Scen[iscen], Group[iscen], t) # make sure this is consistent with main.py
    transmission_model$Trachoma_Simulation(inputbeta,
                                       inputMDA,
                                       prevalence_output,
                                       infect_output,
                                       SaveOutput=FALSE,
                                       OutSimFilePath=NULL,
                                       InSimFilePath=NULL)

  res <- read.csv(prevalence_output) # read python output file
  ans <- 100*res[,dim(res)[2]]
  
  
  print(i)
  print(Sys.time())
  
  param[(sum(N[1:(t-1)])+1):sum(N[1:(t)]),1]<-x
  param[(sum(N[1:(t-1)])+1):sum(N[1:(t)]),2]<-y
  param[(sum(N[1:(t-1)])+1):sum(N[1:(t)]),3]<-ans
  
  prop.val <- sapply(1:sum(N[1:t]),function(b)  sum(sapply(1:G2, function(g) PP[[g]] * dprop(param[b,1:2],mu= Mean[[g]], Sig=Sigma[[g]]))) + dprop0(param[b,1], param[b,2]))   ## FIX to be just the proposal density ALSO scale by number of points
  
  first_weight <- sapply(1:sum(N[1:t]), function(b) dprop0(param[b,1], param[b,2])/prop.val[b])   # prior/proposal
  
  
  ans<-param[1:sum(N[1:(t)]),3]
  
  ess<-c()
  WW<-matrix(NA, nrow=n.pixels, ncol=sum(N[1:(t)]))
  for(i in 1:n.pixels){
    w<-sapply(1:length(ans), function(j) length(which((prev[i,]>ans[j]-delta/2) &(prev[i,]<=ans[j]+delta/2)))/sum(first_weight[which((ans>ans[j]-delta/2) & (ans<=ans[j]+delta/2))]) )   # f/g from AMIS paper #### FIX
    ww<-w*first_weight; ww<-ww/sum(ww)  # second weighting, normalizing
    WW[i,]<-ww
    www<-(sum((ww)^2))^(-1)
    ess<-c(ess, www)
    #cat(c(t, "", i,"", www,"\n"))
  }
  
  cat( c("min(ESS)=", min(ess),  ", max(ESS)=", max(ess), "\n"))
  
  ESS<-rbind(ESS, as.numeric(ess))
  
  w1<-c(colSums(WW))
  param[1:sum(N[1:(t)]),4]<-w1

    filename <- sprintf("tests/test_data/param_iteration_%g.csv", t)
    allseeds <- 1:sum(N[1:(t)])
    ret <- data.frame(allseeds, param[1:sum(N[1:(t)]),c(1,3)], t(WW))
    colnames(ret) <- c(
        "seeds", "beta", "sim_prev",
        sapply(1:dim(WW)[1], function(idx) sprintf("iu%g", idx))
    )
    write.csv(file = filename, ret, row.names = F)
    
  if(min(ess)>=ESS.R) stop<-1
  if(t>= T) stop<-1
}


