# Load required packages
#https://www.geoconnect.org

if (!require("pacman")) install.packages("pacman")
pkgs = c("sf", "dplyr", "tmap", "emojifont", "readr")
pacman::p_load(pkgs, character.only = T)

DataScenarios = read.csv("DataScenarios.csv")
Predictions = read.csv("trachoma_predictive_locations_updated.csv")
ShapeFile = read.csv("AFRO_shapefile.csv")

Predictions = data.frame(ShapeFile[, 1:7], Predictions)  
Predictions = subset(Predictions, Predictions$Country!="Egypt")
Predictions = subset(Predictions, Predictions$Country!="Yemen")
Predictions = subset(Predictions, Predictions$Country!="Morocco")
Predictions = subset(Predictions, Predictions$geoconnect!=0)

africa_ius = st_read("geodata/africa_ius.shp")
unique(africa_ius$ADMIN0[which(!is.na(africa_ius$ADMIN3))])

Predictions$Country = factor(Predictions$Country, levels = unique(c(levels(africa_ius$ADMIN0),levels(Predictions$Country))))
africa_ius$ADMIN0 = factor(africa_ius$ADMIN0, levels = unique(c(levels(africa_ius$ADMIN0),levels(Predictions$Country))))
Uniq = unique(Predictions$Country)
Uniq[which(!(Uniq %in% africa_ius$ADMIN0))]
sort(unique(africa_ius$ADMIN0))

Predictions$Country[which(Predictions$Country == "Democratic Republic of the Congo")] = "Congo, DRC"
Predictions$Country[which(Predictions$Country == "Tanzania")] = "Tanzania (Mainland)"
Predictions$Country[which(Predictions$Country == "Zanzibar")] = "Tanzania (Zanzibar)"
#Uniq = unique(Predictions$Country)
#Uniq[which(!(Uniq %in% africa_ius$ADMIN0))]

africa_ius$IUs_NAME = factor(africa_ius$IUs_NAME, levels = unique(c(levels(africa_ius$IUs_NAME),levels(Predictions$ADMIN2), levels(Predictions$ADMIN3))))
Predictions$ADMIN2 = factor(Predictions$ADMIN2, levels = unique(c(levels(africa_ius$IUs_NAME),levels(Predictions$ADMIN2), levels(Predictions$ADMIN3))))
Predictions$ADMIN3 = factor(Predictions$ADMIN3, levels = unique(c(levels(africa_ius$IUs_NAME),levels(Predictions$ADMIN2), levels(Predictions$ADMIN3))))

africa_ius$ADMIN1 = factor(africa_ius$ADMIN1, levels = unique(c(levels(africa_ius$ADMIN1),levels(Predictions$ADMIN1))))
Predictions$ADMIN1 = factor(Predictions$ADMIN1, levels = unique(c(levels(africa_ius$ADMIN1),levels(Predictions$ADMIN1))))

africa_ius$ADMIN1[which(africa_ius$ADMIN1 == "Oromiya")] = "Oromia"
africa_ius$ADMIN1[which(africa_ius$ADMIN1 == "SNNP")] = "SNNPR"

Uniq = unique(Predictions$ADMIN1)
IUcodes = read.csv("IUcodeTrachomaGroups.csv")

Codes = factor(rep(NA, nrow(Predictions)), levels = unique(c(levels(africa_ius$IU_ID), levels(IUcodes$geo_id))))

for (i in 1:nrow(Predictions))
{
  pos = which(IUcodes$geo_id == Predictions$geoconnect[i])
  if (length(pos) == 1) { 
    Codes[i] = IUcodes$IUcode[pos]
  } else if (length(pos) > 1) {
    Codes[i] = IUcodes$IUcode[pos[1]]
  }
}
length(which(!is.na(Codes)))
length(which(!is.na(IUcodes$IUcode)))

start = 1
# start = 6365
for (i in start:nrow(Predictions))
{
  if (is.na(Codes[i]) & (Predictions$Country[i]!="Algeria" & Predictions$Country[i]!="Burundi")){
    countrypos = which(africa_ius$ADMIN0 == Predictions$Country[i])
    if (length(countrypos)>0)
    {
      if (Predictions$ADMIN3[i] =="" | (Predictions$Country[i] != "Ethiopia" & Predictions$Country[i] != "Congo, DRC")){
        iupos = countrypos[which(gsub("-", " ", tolower(africa_ius$IUs_NAME[countrypos])) == gsub("-", " ", tolower(iconv(Predictions$ADMIN2[i],"WINDOWS-1252","UTF-8"))))]
        
        if (length(iupos)==0)
        {
          statepos = countrypos[which(africa_ius$ADMIN1[countrypos] == Predictions$ADMIN1[i])]
          if (length(statepos)!=0)
          {
            matchsum = rep(NA, length(statepos))
            
            for (j in 1:length(statepos))
            {
              a = unlist(strsplit(tolower(as.character(africa_ius$IUs_NAME[statepos[j]])),""))
              b = unlist(strsplit(tolower(as.character(iconv(Predictions$ADMIN2[i],"WINDOWS-1252","UTF-8"))),""))
              matchsum[j] = sum(!is.na(pmatch(a, b)))
            }
            flag = 1
            maxi = max(matchsum) 
            uniquematch = unique(matchsum)
            uniquematch = uniquematch[-which(unique(uniquematch)==maxi)]
            while(flag==1){
              
              iupos = statepos[which(matchsum == maxi)]
              
              if (length(iupos)>1){
                print(data.frame(i, Predictions$Country[i], africa_ius$IUs_NAME[iupos],africa_ius$ADMIN1[iupos], africa_ius$IU_ID[iupos], Predictions$ADMIN2[i], Predictions$ADMIN1[i]))
                continue = readline(prompt="Continue: ")
              } else {continue = "y"}
              
              if (continue!="n"){
                for (j in 1:length(iupos))
                {
                  print(data.frame(i, Predictions$Country[i], africa_ius$IUs_NAME[iupos[j]], africa_ius$ADMIN1[iupos[j]], africa_ius$IU_ID[iupos[j]], Predictions$ADMIN2[i], Predictions$ADMIN1[i]))
                  accept = readline(prompt="Accept: ")
                  if (accept == "n"){ 
                  } else {Codes[i] = africa_ius$IU_ID[iupos[j]]
                  flag = 0
                  break}
                }
              }
              if (flag == 1 & maxi >=2 & length(uniquematch)>1) {
                maxi = max(uniquematch)
                uniquematch = uniquematch[-which(unique(uniquematch)==maxi)]
              } else if (maxi <2 | length(uniquematch)==1) {
                flag = 0
              }
            }
          }
        } else {
          Codes[i] = africa_ius$IU_ID[iupos]
        }
      } else {
        iupos = countrypos[which(gsub("-", " ", tolower(africa_ius$IUs_NAME[countrypos])) == gsub("-", " ", tolower(Predictions$ADMIN3[i])))]
        
        if (length(iupos)==0)
        {
          statepos = countrypos[which(africa_ius$ADMIN1[countrypos] == Predictions$ADMIN1[i])]
          if (length(statepos)!=0)
          {
            matchsum = rep(NA, length(statepos))
            
            for (j in 1:length(statepos))
            {
              a = unlist(strsplit(tolower(as.character(africa_ius$IUs_NAME[statepos[j]])),""))
              b = unlist(strsplit(tolower(as.character(Predictions$ADMIN3[i])),""))
              matchsum[j] = sum(!is.na(pmatch(a, b)))
            }
            
            flag = 1
            maxi = max(matchsum) 
            uniquematch = unique(matchsum)
            uniquematch = uniquematch[-which(unique(uniquematch)==maxi)]
            while(flag==1){
              
              iupos = statepos[which(matchsum == maxi)]
              
              if (length(iupos)>1){
                print(data.frame(i, Predictions$Country[i], africa_ius$IUs_NAME[iupos], africa_ius$ADMIN2[iupos], africa_ius$IU_ID[iupos], Predictions$ADMIN3[i], Predictions$ADMIN2[i]))
                continue = readline(prompt="Continue: ")
              } else {continue = "y"}
              
              if (continue!="n"){
                for (j in 1:length(iupos))
                {
                  print(data.frame(i, Predictions$Country[i], africa_ius$IUs_NAME[iupos[j]], africa_ius$ADMIN2[iupos[j]], africa_ius$IU_ID[iupos[j]], Predictions$ADMIN3[i], Predictions$ADMIN2[i]))
                  accept = readline(prompt="Accept: ")
                  if (accept == "n"){ 
                  } else {Codes[i] = africa_ius$IU_ID[iupos[j]]
                  flag = 0
                  break}
                }
              }
              if (flag == 1 & maxi >=2 & length(uniquematch)>1) {
                maxi = max(uniquematch)
                uniquematch = uniquematch[-which(unique(uniquematch)==maxi)]
              } else if (maxi <2 | length(uniquematch)==1) {
                flag = 0
              }
            }
            
          }
        } else {
          Codes[i] = africa_ius$IU_ID[iupos]
        } 
      }
    }
  } 
}

Codes[163] = "ETH19082"
Codes[1559] = "SDN53248"
Codes[5861] = "COG12829"


CodesFinal = Codes

#write.csv(data.frame(Predictions, Codes), file = "PredictionsIUcodes.csv", row.names = F)

DataFinal = read.csv("PredictionsIUcodesFinal.csv")
DataScenarios = read.csv("DataScenarios.csv")

Scenarios = matrix(NA, nrow = nrow(DataFinal), ncol = 3)
for (i in 1:nrow(DataFinal))
{
  pos = which(DataFinal$geoconnect[i] == DataScenarios$Geoconnect_ID)
  if (length(pos) == 1){
  Scenarios[i, ] = unlist(DataScenarios[pos, 55:57])
  } else if (length(pos) > 1){
    Scen = which.max(DataScenarios[pos, 57])
    Scenarios[i, ] = unlist(DataScenarios[pos[Scen], 55:57])
  }
}

length(which(is.na(Scenarios[, 1])))

DataAll = data.frame(Country = DataFinal$Country, Region = DataFinal$Region, 
                     District = DataFinal$District, Subdistrict = DataFinal$Subdistrict, 
                     Geoconnect_ID = DataFinal$geoconnect, Pop_point = DataFinal$pop_point,
                     Pop_district = DataFinal$pop_district, Logit = DataFinal$logit, 
                     Sds = DataFinal$standard.errors, IUCodes = DataFinal$Codes, start_MDA = Scenarios[, 1], 
                     last_MDA = Scenarios[, 2], Scenario = Scenarios[, 3]) 

DataAll = subset(DataAll, !is.na(IUCodes))
DataAll = subset(DataAll, !is.na(Scenario))
dim(DataAll)
length(unique(DataAll$IUCodes))

CodeUni = unique(DataAll$IUCodes)
for (i in 1:length(CodeUni))
{
  pos = which(DataAll$IUCodes == CodeUni[i])
  if (length(pos)>1)
  {
    print(pos)
    print(DataAll[pos, ])
    readline("Enter")
  }
}

DataAll$IUCodes = factor(DataAll$IUCodes, levels = unique(c(levels(africa_ius$IU_ID),levels(DataAll$IUCodes))))
DataAll$IUCodes[422] = "ETH18932"
DataAll$IUCodes[613] = "ETH18652"
DataAll$IUCodes[36] = "ETH19098"
DataAll$IUCodes[3789] = "SEN40178"
DataAll$IUCodes[431] = "ETH18889"
DataAll$IUCodes[432] = "ETH19334"
DataAll$IUCodes[439] = "ETH18775"
DataAll$IUCodes[480] = "ETH19331"
DataAll$IUCodes[103] = "ETH18887"
DataAll$IUCodes[475] = "ETH18780"
DataAll$IUCodes[517] = "ETH18914"
DataAll$IUCodes[573] = NA
DataAll$IUCodes[481] = "ETH18808"
DataAll$IUCodes[554] = "ETH18939"
DataAll$IUCodes[571] = "ETH18856"
DataAll$IUCodes[1329] = NA
DataAll$IUCodes[610] = "ETH19323"
DataAll$IUCodes[2968] = NA
DataAll$IUCodes[c(37,   80,  149, 38,   39,   40, 643, 644, 747, 722, 723, 724, 731, 725, 733, 734, 726,  735,  736, 1296, 1297, 1298, 
                  727, 732, 728,  737,  738, 729, 740, 730, 739, 741, 742, 751,  752,  753,
                  743,  744,  745,  746, 748,  749,  750, 754,  755,  756,  757,  758,
                  759, 760, 761, 762, 763, 1278, 1279, 1280, 1281, 1282,  1283, 1284,
                  1285, 1292, 1286, 1289, 1287, 1290, 1288, 1291, 1293, 1294, 1295,
                  1299, 1303, 1300, 1304, 1301, 1305, 1302, 1306, 1307, 1308, 1309, 1324,
                  1310, 1321,1311, 1322, 1312, 1319, 1313, 1323, 1314, 1325, 1315, 1320,
                  1316, 1326, 1317, 1318)] = NA
DataAll$IUCodes[767] = "COD13903"
DataAll$IUCodes[876] = "COD14057"
DataAll$IUCodes[1201] = NA
DataAll$IUCodes[2693] = "NGA36831"
DataAll$IUCodes[2697] = "NGA36835"
DataAll$IUCodes[2671] = "NGA36808"
DataAll$IUCodes[4380] = NA
DataAll$IUCodes[2718] = "NGA36872"
DataAll$IUCodes[2498] = "NGA36472"
DataAll$IUCodes[2716] = "NGA36870"
DataAll$IUCodes[3762] = "SEN40182"
DataAll$IUCodes[3908] = NA
DataAll$IUCodes[4410] = NA
DataAll$IUCodes[1327] = "ETH18633"
DataAll$IUCodes[531] = "ETH18885"

DataAll = subset(DataAll, !is.na(IUCodes))
dim(DataAll)
length(unique(DataAll$IUCodes))

CodeUni = unique(DataAll$IUCodes)
for (i in 1:length(CodeUni))
{
  pos = which(DataAll$IUCodes == CodeUni[i])
  if (length(pos)>1)
  {
    print(pos)
    print(DataAll[pos, ])
    readline("Enter")
  }
}

DataAll$IUCodes[c(156,1509,3434, 3666)] = NA
DataAll$IUCodes[c(363,2926, 3646, 3810)] = NA

DataAll = subset(DataAll, !is.na(IUCodes))
dim(DataAll)
length(unique(DataAll$IUCodes))

write.csv(DataAll, file = "FinalData.csv", row.names = F)




