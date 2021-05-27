Data = read.csv("./data/FinalDataPrev.csv")
DataScenarios = data.frame(Data$start_MDA, Data$last_MDA, Data$Scenario, Data$Group)
DataScenarios = unique(DataScenarios)
DataScenarios = DataScenarios[-which(DataScenarios$Data.Group == 7), ]

Scen = DataScenarios$Data.Scenario
Group = DataScenarios$Data.Group

iscen <- 1
IU_scen <- which(Data$Scenario == Scen[iscen] & Data$Group == Group[iscen])

set.seed(iscen)
prev = matrix(NA, ncol = n.map.sampl, nrow = length(IU_scen))
for (i in 1:length(IU_scen))
{
  set.seed(Scen[iscen])
  L = rnorm(n.map.sampl, Data$Logit[IU_scen[i]], sd = Data$Sds[IU_scen[i]])
  prev[i, ] = exp(L)/(1+exp(L))
}
prev <- prev*100
write.table(prev, file = "prevalence_map.csv", row.names = F, col.names = F)
