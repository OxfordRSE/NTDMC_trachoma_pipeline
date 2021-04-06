
Data = read.csv("/Users/Panayiota/Desktop/Back\ Up/Trachoma/Swatis_code/Swatis_code_cluster/FinalData.csv")
Scenarios = Data$Scenario
Group = rep(NA, dim(Data)[1])
n.map.sampl = 3000
for (i in 1:dim(Data)[1])
{
set.seed(Scenarios[i])
L = rnorm(n.map.sampl, Data$Logit[i], sd = Data$Sds[i])
prev = exp(L)/(1+exp(L))
prev = prev*100
MeanPrev = mean(prev)
if (MeanPrev>=0 & MeanPrev<10)
{
  Group[i] = 1
} else if (MeanPrev>=10 & MeanPrev<20) {
  Group[i] = 2
} else if (MeanPrev>=20 & MeanPrev<30) {
  Group[i] = 3
} else if (MeanPrev>=30 & MeanPrev<40) {
  Group[i] = 4
} else if (MeanPrev>=40 & MeanPrev<50) {
  Group[i] = 5
} else if (MeanPrev>=50 & MeanPrev<60) {
  Group[i] = 6
} else {
  Group[i] = 7
}
}

write.csv(file = "FinalDataPrev.csv", cbind(Data, Group), row.names = F)

GroupPrev = unique(data.frame(Scenario = Scenarios, Group = Group))
GroupPrev = GroupPrev[-which(GroupPrev$Group == 7), ]

write.csv(GroupPrev, file = "GroupPrev.csv", row.names = F)

