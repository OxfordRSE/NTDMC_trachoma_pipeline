![Illustration of trachoma pipeline](./diagramm.png)

# 1 - Generating IUCodes from geoconnect IDs

Original data provided by ????, location are identified by geoconnect ID
```
# data_cleaning/AFRO_shapefile.csv

ADMIN0ID,ADMIN1,ADMIN1ID,ADMIN2,ADMIN2ID,ADMIN3,ADMIN3ID,ADMIN0,geoconnect,Shape_Leng,Shape_Area,long,lat
24.000000000000000,Amhara,609.000000000000000,N. Shoa,26086.000000000000000,Baso Naworana,660.000000000000000,Ethiopia,6303.000000000000000,0.495734156180000,0.006293784810000,39.378936736202200,9.710504722218760
24.000000000000000,Amhara,609.000000000000000,West Gojam,3193.000000000000000,Gongi Kolela,289.000000000000000,Ethiopia,6217.000000000000000,0.665967526200000,0.018789127440000,37.675122928922600,11.319006794396100
...
```

*Goal*: The goal is to give location the correct IU code based on the geoconnect ID.

This is done by `data_cleaning/FindIUCode.R`. This script relies on the following data files

- `DataScenarios.csv`: Describe surveys and scenario per location. Locations are identified by Geoconnect ID
- `trachoma_predictive_locations_updated.csv`: The list of locations at which we want to predict trachoma prevalence
- `AFRO_shapefile.csv`: **???**. Locations are described by Geoconnect ID.
- `IUCodeTrachomaGroups.csv`: Maps geoconnect ids to IU code for some locations. **group no is already there?**.
- `geodata/africa_ius.shp`: **???**

Purpose of file `PredictionsIUCodesFinal.csv` is unclear. Intermediate manual step?

```R
CodesFinal = Codes

#write.csv(data.frame(Predictions, Codes), file = "PredictionsIUcodes.csv", row.names = F)

DataFinal = read.csv("PredictionsIUcodesFinal.csv")
```

The output of this step is the file `FinalData.csv`, with both the Geoconnect ID and the IU Code.

```
# data_cleaning/FinalData.csv
"Country","Region","District","Subdistrict","Geoconnect_ID","Pop_point","Pop_district","Logit","Sds","IUCodes","start_MDA","last_MDA","Scenario"
"Ethiopia","Amhara","N. Shoa","Baso Naworana",6303,161.3058472,13128.23101,-1.814302776,0.243590266,"ETH18551",2008,2017,36
"Ethiopia","Amhara","West Gojam","Gongi Kolela",6217,288.9628601,69764.48892,-1.28066311,0.255922043,"ETH18604",2008,2019,28
...
```

# 2 - Sample an ensemble of parameter sets using AMIS

Model parameters are *????*
We want to find the right transmission model parameters at each location.
Based on geostatistical data (obseverd distribution of parameters at different locations), we use the AMIS algorithm to
sample a set of 200 parameters from a distribution that best matches the observed distribution of parameters.

With these parameters and the associated statistical weight, we can
then run 200 simulations and predict prevalence statistics at each
location.


## 2.1 - Group scenarios according to mean prevalence

Each location is associated a scenario, identified by an integer index.
```
# data_cleaning/FinalData.csv
"Country","Region","District","Subdistrict",...,"IUCodes","start_MDA","last_MDA","Scenario"
"Ethiopia","Amhara","N. Shoa","Baso Naworana",...,"ETH18551",2008,2017,36
```
**What is a scenario? start date of MDA and end date of MDA?**

We assign each location (IU) in the data (`FinalData.csv`), to a given group, based on the mean prevalence.

The output of this steps is a new data file `find_200_values/FinalDataPrev.csv` with an additional column indicating the prevalence group:

```
# find_200_values/FinalDataPrev.csv

"Country","Region","District","Subdistrict",...,"IUCodes","start_MDA","last_MDA","Scenario","Group"
"Ethiopia","Amhara","N. Shoa","Baso Naworana",...,"ETH18551",2008,2017,36,2
"Ethiopia","Amhara","West Gojam","Gongi Kolela",...,"ETH18604",2008,2019,28,3
```

**Are we grouping scenarios or IUs?**
**Does the group number depend on the IU or the scenario?**

## 2.2 - Prepare python codes to run the transmission model within the AMIS algorithm

The trachoma transmission model is implemented in Python (`find_200_values/trachoma`).

At each iteration of the AMIS algorithm, we must run the model for $N_t=100$ sets of parameters for every IU, according to the scenario of the IU.

The AMIS algorithm is run in parallel for each scenario, to sample parameter sets for the IU associated with this scenario.

The trachoma transimission model is run from a function `test` defined in a file `main_trachoma_run_scenX_groupY.py` with `X` the scenario index and `Y` the group index.

```python
# find_200_values/main_trachoma_run_scen36_group2.py

from trachoma.trachoma_simulations import Trachoma_Simulation

def test():
	 Trachoma_Simulation(BetFilePath='files/InputBet_scen36_group2.csv',
	 	 	 	 MDAFilePath='files/InputMDA_scen36.csv',
	 	 	 	 PrevFilePath='output/OutputPrev_scen36_group2.csv',
	 	 	 	 InfectFilePath='output/InfectFilePath_scen36_group2.csv',
	 	 	 	 SaveOutput=False,
	 	 	 	 OutSimFilePath=None,
	 	 	 	 InSimFilePath=None)
```

The AMIS script (R) calls another file `main_trachoma_scenX_groupY.py` that calls `test()`.

Before the AMIS is run, python files are prepared for each scenario. this is done using script `CreateFilesPrev.R`

```R
# find_200_values/CreateFilesPrev.R
  
filename = paste("main_trachoma_scen", Scen[i], "_group", Group[i], ".py", sep="")
cat(file=filename, paste("test()"), append = F)
  
filename = paste("main_trachoma_run_scen", Scen[i], "_group", Group[i], ".py", sep="")
FilePrev(filename, i)
```

In addition, the scenario parameters are written in a file `files/InputMDA_scenX.csv` for
each scenario.  This file is one of the two input file required by the trachoma model
code, along with `InputBet_scenX_groupY.csv` which lists the values for the different sets
of parameters.

## 2.3 - Run the AMIS algorithm in parallel for each scenario

The R script `Trachoma_AMIS_perprev` is in parallel for each scenario. The scenario index
is mapped to the task ID given by the job scheduler.

```R
iscen = as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))
```

**Which script is used to submit the jobs?**

The AMIS is an iterative procedure to sample parameters according to a distribution that best matches the available data.

### First iteration

We start with a set of $N$ parameters sampled from an initial guess and compute the
prevalence corresponding to each of them, running the transimission model for the scenario.

```R
t<-1  # First iteration
tmp<-rprop0(N[t])    #N[t] random draws of parameters from prior
x <- tmp[[1]]  # bet
y <- tmp[[2]]  # constant
seed <- c(1:N[t])
allseed <- seed
input_params <- cbind(seed, x)
colnames(input_params) = c("randomgen", "bet")
write.csv(input_params, file=inputbeta, row.names=FALSE)

### Run Python
source_python(run_py_file)
```

The transimission model writes a file `output/OutputPrev_scenX_groupY.csv` (`prevalence_output`) that contains the computed prevalences for each parameter set.
This file is read and each parameter set is weighted according to the observed prevalence values (`prev`)

```R
# read in python output file
res <- read.csv(prevalence_output)
ans <- 100*res[,dim(res)[2]]

#weights over all IUs
w<-sapply(1:length(ans), function(i) length(which((prev>ans[i]-delta/2) &(prev<=ans[i]+delta/2)))/length(which((ans>ans[i]-delta/2) & (ans<=ans[i]+delta/2))))
```

Based on these weights, and effective sample size is computed that is used to determine whether or not the algorithm has converged for a given IU.

### Second and follwing iterations

At each subsequent iteration, a new proposal distribution is sampled building on the proposal distribution sampled at the previous step.

The algorithm stops when each IU as reached the effective sample size.

The output of the AMIS is a set of $N$ parameter sets and their associated weight for each IU. This is stored into a dataframe `sparamWW` which is written to disk
as `sparamWW.csv.`

### Sampling 200 parameter sets

Given the ensemble of parameter sets and their respective weight, $n=200$ parameters are sampled for the current scenario.
These parameter values are written in `files200/InputBet_X.csv` where `X` is the scenario index.

```R
for(i in 1:n.pixels) {
  set.seed(i)
  simul = sample.int(length(sparamWW[, 3]), 200, replace = F, prob = sparamWW[, i+4])
  InitValues = cbind(sparamWW[simul, 1], sparamWW[simul, 2])
  colnames(InitValues) = c("randomgen", "bet")
  write.csv(InitValues, file = paste("files200/InputBet_", IU_scen_name[i], ".csv", sep=""), row.names = F)
  file.copy(from=sprintf("files/InputMDA_scen%g.csv", Scen[iscen]), to = paste("files200/InputMDA_", IU_scen_name[i], ".csv", sep=""))
}
```

# 3 - Running the transmission model for the 200 parameter sets
