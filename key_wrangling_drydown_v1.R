###################################
# Written by: Charlie Hale (chale295@gmail.com)
# June 2021
# OBJECTIVE: Create a simplified key for James' drydown dataset, mapping randomized pot IDs
# to treatments and population metadata (species, zone, coordinates).
# INPUTS: Drydown mapping key ("jamesdrydown_6_29_21.xlsx"), population data ("sc_texas_hybridzone_growout_2020.12.16.xlsx"), 
# OUTPUT: Cleaned data file ("key_drydown_06.29.21.csv")

library(dplyr)
library(readxl)
library(tidyr)

setwd("~/Desktop/Ecophys/Analysis/data/")

# Import data, dropping unnecessary columns
raw_key <- read_excel("jamesdrydown_7.28.21.xlsx", sheet="Active_Datasheet") %>%
  select(c("pot.id", cross.id = "cross.id_corrected", treatment = "wd", "end_species"))

pop_data <- read_excel("sc_texas_hybridzone_growout_2020.12.16.xlsx", sheet = "master") %>%
  select(c("PopID", "Latitude", "Longitude", "Species", "Zone"))

# Split cross ID into separate maternal and paternal IDs
key <- separate(raw_key, cross.id, into = c("Mat_ID", "Pat_ID"), sep = " x ") %>%
  
# Create separate columns with maternal and paternal population IDs
  separate(Mat_ID, into = c("Mat_Pop"), sep = "-", remove = FALSE, extra = "drop") %>%
  separate(Pat_ID, into = c("Pat_Pop"), sep = "-", remove = FALSE, extra = "drop")
  
# Merge key with pop data
mat_pops <- select(pop_data, c(Mat_Pop = "PopID", Mat_Lat = "Latitude", Mat_Long = "Longitude", 
                               Mat_Species = "Species", Mat_Zone = "Zone"))
pat_pops <- select(pop_data, c(Pat_Pop = "PopID", Pat_Lat = "Latitude", Pat_Long = "Longitude", 
                               Pat_Species = "Species", Pat_Zone = "Zone"))

merged_key <- merge(key, mat_pops) %>%
              merge(pat_pops) %>%

# Check for species mismatches
#merged_key[merged_key$Pat_Species != merged_key$end_species,]

# pot 64 was marked as drummondii at end, but should be cuspidata, everything else looks good


# Rearrange columns
select(pot.id, treatment, Mat_Species, Pat_Species, Mat_ID, Pat_ID, Mat_Pop, Pat_Pop, Mat_Lat, 
       Pat_Lat, Mat_Long, Pat_Long, Mat_Zone, Pat_Zone) %>%
  arrange(pot.id)

# Export as a CSV
write.csv(merged_key, file = "key_drydown_07.28.21.csv", row.names = FALSE)







