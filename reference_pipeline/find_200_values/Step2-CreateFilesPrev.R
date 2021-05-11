Data = read.csv("FinalDataPrev.csv")
DataScenarios = data.frame(Data$start_MDA, Data$last_MDA, Data$Scenario, Data$Group)
DataScenarios = unique(DataScenarios)
DataScenarios = DataScenarios[-which(DataScenarios$Data.Group == 7), ]

Scen = DataScenarios$Data.Scenario
start_MDA = DataScenarios$Data.start_MDA
last_MDA = DataScenarios$Data.last_MDA
Group = DataScenarios$Data.Group

source("Createpy.R")
for (i in 1:length(Scen))
{
  if (start_MDA[i] != 0){
    start_sim_year = start_MDA[i] - 1 
    end_sim_year = 2019
    first_mda = start_MDA[i]
    last_mda = last_MDA[i]
  } else {
    start_sim_year = 2019
    end_sim_year = 2019
    first_mda = NA
    last_mda = NA
  }
  
  write.csv(data.frame(start_sim_year, end_sim_year, first_mda, last_mda), file = sprintf("files/InputMDA_scen%g.csv", Scen[i]), row.names = F)

  filename = paste("main_trachoma_scen", Scen[i], "_group", Group[i], ".py", sep="")
  cat(file=filename, paste("test()"), append = F)
  
  filename = paste("main_trachoma_run_scen", Scen[i], "_group", Group[i], ".py", sep="")
  FilePrev(filename, i)
    
}
    
