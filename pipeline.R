iscen <- 1

### Read data
data <- read.csv("./data/FinalData.csv")
grouped_data <- trachomapipeline::group_ius_according_to_mean_prevalence(data)

scenario_id <- trachomapipeline::get_scenario_id(grouped_data, iscen)
group_id <- trachomapipeline::get_group_id(grouped_data, iscen)

IU_scen <- which(
    grouped_data$Scenario == scenario_id & grouped_data$Group == group_id
)
prevalence_map <- sample_prevalence_map_at_IUs(
    IU_scen, n.map.sampl = 3000, scenario_id
)

transmission_model <- reticulate::import("trachoma")
model_func <- transmission_model$Trachoma_Simulation
param_and_weights <- trachomAMIS::amis(prevalence_map = prev,
                                      transmission_model = model_func,
                                      n_params = 2, nsamples = 100,
                                      IO_file_id = sprintf("scen%g_group%g",
                                                           scenario_id,
                                                           group_id),
                                      delta = 5,
                                      T = T,
                                      target_ess = 250
                                  )
## Resample N trajectories
inputMDA <- sprintf("files/InputMDA_scen%g.csv", scenario_id, group_id)
for (i in 1:length(IU_scen)) {
    weights <- param_and_weights[,i+3]
    param_and_weights_for_iu <- cbind(
        param_and_weights[,1:2], weights
    )
    
    init_values <- sample_init_values(param_and_weights_for_iu)
    inputbeta <- paste("files200/InputBet_", IU_scen[i], ".csv", sep="")
    prevalence_output <- paste("output200/OutputPrev_", IU_scen[i], ".csv'", sep="")
    prevalence_output <- paste("OutSimFilePath='output200/OutputVals_", IUCodes[i], ".p'", sep="")
    infect_output <- paste("InfectFilePath='output200/InfectFilePath_", IUCodes[i], ".csv'", sep="")
    outputs_file <- paste("OutSimFilePath='output200/OutputVals_", IUCodes[i], ".p'", sep="")
    write.csv(
        init_values,
        file = inputbeta,
        row.names = F
    )
    model_func(
        inputbeta,
        inputMDA,
        prevalence_output,
        infect_output,
        SaveOutput=FALSE,
        OutSimFilePath=outputs_file,
        InSimFilePath=NULL
    )
    
}
