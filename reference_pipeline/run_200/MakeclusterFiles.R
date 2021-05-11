#Data = read.csv("/Users/Panayiota/Desktop/Back\ Up/Trachoma/Swatis_code/Swatis_code_cluster/MoreGroups/FinalDataPrev.csv")
Data = read.csv("FinalDataPrev.csv")
DataScenarios = data.frame(Data$IUCodes, Data$Scenario, Data$Group)
DataScenarios = unique(DataScenarios)
DataScenarios = DataScenarios[-which(DataScenarios$Data.Group == 7), ]

IUCodes = DataScenarios$Data.IUCodes

for (i in 1:length(IUCodes))
{
  
  filename = paste("IU", IUCodes[i], sep="_")
  cat(file=filename, "#!/bin/bash",  "\n", append = F)
  cat(file=filename, "#SBATCH --nodes=1" ,  "\n", append = T)
  cat(file=filename, "#SBATCH --ntasks-per-node=4" ,  "\n", append = T)
  cat(file=filename, "#SBATCH --time=11:59:00" ,  "\n", append = T)
  if (i >= (length(IUCodes)/3))
  {
  cat(file=filename, "#SBATCH --partition=ntd" , "\n", append = T)
  } else
  {
    cat(file=filename, "#SBATCH --partition=hat" , "\n", append = T)
  }
  cat(file=filename, "\n", append = T)
  cat(file=filename, "export PATH=$HOME/python3/Python-3.8.6/:$PATH", "\n", append = T)
  cat(file=filename, "export PYTHONPATH=$HOME/python3/Python-3.8.6", "\n", append = T)
  cat(file=filename, "export PATH=$HOME/.local/bin:$PATH", "\n", append = T)
  cat(file=filename, "export PATH=$HOME/python3/bin:$PATH", "\n", append = T)
  cat(file=filename, "\n", append = T)
  cat(file=filename, paste("BetFilePath='files200/InputBet_", IUCodes[i], ".csv'", sep=""), "\n", append = T)
  cat(file=filename, paste("MDAFilePath='files200/InputMDA_", IUCodes[i], ".csv'", sep=""), "\n", append = T)
  cat(file=filename, paste("PrevFilePath='output200/OutputPrev_", IUCodes[i], ".csv'", sep=""), "\n", append = T)
  cat(file=filename, paste("InfectFilePath='output200/InfectFilePath_", IUCodes[i], ".csv'", sep=""), "\n", append = T)
  cat(file=filename, paste("OutSimFilePath='output200/OutputVals_", IUCodes[i], ".p'", sep=""),"\n", append = T)
  cat(file=filename, "\n", append = T)
  cat(file=filename, "python trachoma_run200.py $BetFilePath $MDAFilePath $PrevFilePath $InfectFilePath $OutSimFilePath", append = T)
  
  name = paste("sbatch ", paste("IU", IUCodes[i], sep="_"))
  cat(file="Send.txt", name,  "\n", append = T)
  
}






