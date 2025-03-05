# Optimal Sampling
# Application on NHANES 2017-2018 dataset
# clean original datasets

# Load necessary libraries
library(haven)  # For reading SAS XPT files
library(dplyr)  # For data manipulation

# Set relative path
current_dir <- getwd()
nhanes_dir <- paste(c(current_dir, "data_raw"), collapse="/")

# List of dataset names (without file extensions)
dataset_names <- c(
  "DEMO_J", "HOQ_J", "COT_J", "ALB_CR_J", "UTAS_J", "TCHOL_J", "CRCO_J", "CBC_J",
  "CMV_J", "ETHOX_J", "FERTIN_J", "FR_J", "SSFR_J", "FOLATE_J", "FOLFMS_J", "GHB_J",
  "HEPA_J", "HEPBD_J", "HEPC_J", "HEPE_J", "HSCRP_J", "HIV_J", "INS_J", "UIO_J",
  "FETIB_J", "PBCD_J", "IHGEM_J", "UM_J", "UNI_J", "OPD_J", "PERNT_J", "PFAS_J",
  "PHTHTE_J", "GLU_J", "BIOPRO_J", "TFR_J", "VITAEC_J", "VIC_J", "VID_J", "UVOC_J",
  "SSUVOC_J", "VOCWB_J"
)

# Create an empty list to store datasets
datasets <- list()

# Loop through each dataset and process it
for (dataset in dataset_names) {
  # Construct full file paths
  input_path <- paste0(nhanes_dir, "/", dataset, ".XPT")
  output_path <- paste0(nhanes_dir, "/", dataset, ".csv")
  
  # Read SAS XPT file
  data <- read_xpt(input_path)
  
  # Save as CSV
  write.csv(data, output_path, row.names = FALSE)
  
  # Store dataset in the list with its name
  datasets[[dataset]] <- data
  
  # Print progress
  print(paste("Processed:", dataset))
}

print("All datasets have been successfully converted to CSV!")

# Assign datasets to individual variables
data_DEMO <- datasets[["DEMO_J"]]
data_HOQ <- datasets[["HOQ_J"]]
data_COT <- datasets[["COT_J"]]
data_ALB_CR <- datasets[["ALB_CR_J"]]
data_UTAS <- datasets[["UTAS_J"]]
data_TCHOL <- datasets[["TCHOL_J"]]
data_CRCO <- datasets[["CRCO_J"]]
data_CBC <- datasets[["CBC_J"]]
data_CMV <- datasets[["CMV_J"]]
data_ETHOX <- datasets[["ETHOX_J"]]
data_FERTIN <- datasets[["FERTIN_J"]]
data_FR <- datasets[["FR_J"]]
data_SSFR <- datasets[["SSFR_J"]]
data_FOLATE <- datasets[["FOLATE_J"]]
data_FOLFMS <- datasets[["FOLFMS_J"]]
data_GHB <- datasets[["GHB_J"]]
data_HEPA <- datasets[["HEPA_J"]]
data_HEPBD <- datasets[["HEPBD_J"]]
data_HEPC <- datasets[["HEPC_J"]]
data_HEPE <- datasets[["HEPE_J"]]
data_HSCRP <- datasets[["HSCRP_J"]]
data_HIV <- datasets[["HIV_J"]]
data_INS <- datasets[["INS_J"]]
data_UIO <- datasets[["UIO_J"]]
data_FETIB <- datasets[["FETIB_J"]]
data_PBCD <- datasets[["PBCD_J"]]
data_IHGEM <- datasets[["IHGEM_J"]]
data_UM <- datasets[["UM_J"]]
data_UNI <- datasets[["UNI_J"]]
data_OPD <- datasets[["OPD_J"]]
data_PERNT <- datasets[["PERNT_J"]]
data_PFAS <- datasets[["PFAS_J"]]
data_PHTHTE <- datasets[["PHTHTE_J"]]
data_GLU <- datasets[["GLU_J"]]
data_BIOPRO <- datasets[["BIOPRO_J"]]
data_TFR <- datasets[["TFR_J"]]
data_VITAEC <- datasets[["VITAEC_J"]]
data_VIC <- datasets[["VIC_J"]]
data_VID <- datasets[["VID_J"]]
data_UVOC <- datasets[["UVOC_J"]]
data_SSUVOC <- datasets[["SSUVOC_J"]]
data_VOCWB <- datasets[["VOCWB_J"]]



# Select pretreatment variables of interest
data_complete <- merge(data_DEMO, data_HOQ, by = 'SEQN')

# From DEMO dataset
# - EDUCATION (years of education of the reference adult): DMDHREDZ
# - MALE/FEMALE (gender of the participant): RIAGENDR
# - NON-WHITE/WHITE (race/ethnicity): RIDRETH1
# - POVERTY (income divided by poverty threshold): INDFMPIR
# - FAMILY (size of family): DMDHHSIZ
# - AGE (age in years at screening): RIDAGEYR
# From HOQ dataset
# - ROOM (number of rooms in the house): HOD050
data_pretreat <- data_complete %>%
  select(SEQN, DMDHREDZ, RIAGENDR, RIDRETH1, INDFMPIR, DMDHHSIZ, RIDAGEYR, HOD050) %>%
  na.omit() %>%  # Remove missing data
  filter(HOD050 < 14)  # Drop observations with unknown number of rooms

# Print final cleaned dataset summary
print("Pretreatment data cleaning complete. Summary:")
# print(summary(data_pretreat))



# treatment data
# from COT dataset
# COTININE: (Cotinine, Serum in ng/mL): LBXCOT
data_COT_transform = data_COT
data_COT_transform[, "TREAT"] = as.integer(data_COT[, "LBXCOT"] >= 0.563)
data_treatment = data_COT_transform[, c("SEQN", "TREAT")]
# delete missing data observations
data_treatment = na.omit(data_treatment)



# outcome data
data_ALB_CR_outcome = data_ALB_CR[, c("SEQN", "URXUMA", "URXUCR")]
data_TCHOL_outcome = data_TCHOL[, c("SEQN", "LBXTC")]
data_CBC_outcome = data_CBC[, c("SEQN", "LBXWBCSI", "LBDLYMNO", "LBDMONO", "LBDNENO", "LBDEONO", 
                                "LBDBANO", "LBXRBCSI", "LBXHGB", "LBXHCT", "LBXMCVSI", "LBXMCHSI", 
                                "LBXMC", "LBXRDW", "LBXPLTSI", "LBXMPSI", "LBXNRBC")]
data_COT_outcome = data_COT[, c("SEQN", "LBXHCT")]
data_FERTIN_outcome = data_FERTIN[, c("SEQN", "LBXFER")]
data_FOLATE_outcome = data_FOLATE[, c("SEQN", "LBDRFO")]
data_FOLFMS_outcome = data_FOLFMS[, c("SEQN", "LBDFOTSI")]
data_GHB_outcome = data_GHB[, c("SEQN", "LBXGH")]
data_HSCRP_outcome = data_HSCRP[, c("SEQN", "LBXHSCRP")]
data_FETIB_outcome = data_FETIB[, c("SEQN", "LBDTIB")]
data_PBCD_outcome = data_PBCD[, c("SEQN", "LBXBPB", "LBXBCD", "LBXTHG", "LBXBSE", "LBXBMN")]
data_IHGEM_outcome = data_IHGEM[, c("SEQN", "LBXIHG", "LBXBGE", "LBXBGM")]
data_BIOPRO_outcome = data_BIOPRO[, c("SEQN", "LBXSATSI", "LBXSAL", "LBXSAPSI", "LBXSC3SI", "LBXSBU", 
                                      "LBXSCLSI", "LBXSCK", "LBXSCR", "LBXSGB", "LBXSGL", "LBXSGTSI", 
                                      "LBXSIR", "LBXSLDSI", "LBXSOSSI", "LBXSPH", "LBDSPHSI", "LBXSKSI", 
                                      "LBXSNASI", "LBXSTB", "LBXSCA", "LBXSCH", "LBXSTP", "LBXSTR", "LBXSUA")]
data_TFR_outcome = data_TFR[, c("SEQN", "LBXTFR")]
data_VITAEC_outcome = data_VITAEC[, c("SEQN", "LBXALC", "LBXARY", "LBXBEC", "LBXCBC", "LBXCRY", 
                                      "LBXGTC", "LBXLUZ", "LBXLYC", "LBXRPL", "LBXRST", "LBXLCC", 
                                      "LBXVIA", "LBXVIE")]
data_VIC_outcome = data_VIC[, c("SEQN", "LBXVIC")]
data_VID_outcome = data_VID[, c("SEQN", "LBXVIDMS", "LBXVD2MS", "LBXVD3MS", "LBXVE3MS")]

data_outcome_list = list(data_ALB_CR_outcome, data_TCHOL_outcome, data_CBC_outcome, data_COT_outcome, 
                         data_FERTIN_outcome, data_FOLATE_outcome, data_FOLFMS_outcome, data_GHB_outcome, 
                         data_HSCRP_outcome, data_FETIB_outcome, data_PBCD_outcome, data_IHGEM_outcome, 
                         data_BIOPRO_outcome, data_TFR_outcome, data_VITAEC_outcome, data_VIC_outcome, 
                         data_VID_outcome)

data_outcome = Reduce(function(x, y) merge(x, y, all=TRUE), data_outcome_list)
data_outcome = na.omit(data_outcome)
outcome_names = colnames(data_outcome)[-1]



# clean merged data
data_full = Reduce(function(x, y) merge(x, y, all=TRUE), list(data_pretreat, data_treatment, data_outcome))
data_full = na.omit(data_full)
# only keep observations with age from 4~16
data_full_cleaned = data_full[data_full$RIDAGEYR < 16 & data_full$RIDAGEYR > 4, ]
write.csv(data_full_cleaned, paste(c(current_dir, "data_full_cleaned.csv"), collapse="/"), row.names = FALSE)


