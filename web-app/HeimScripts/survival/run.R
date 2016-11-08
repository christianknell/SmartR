# Load libraries
library(survival)

# Global variables
dummy_category <- "NO_CATEGORY_SELECTED"
selected_subsets <- c()
selected_subsets_count <- 0
selected_categories <- c()
selected_categories_count <- 0
legend_labels <- c()
subset_1 <- data.frame()
subset_2 <- data.frame()
data_sets <- list()
survival_data_sets <- list()

# MAIN function which is called by SmartR automatically
main <- function(legendPosition = "right", timeIn = "days", timeOut = "days", mergeSubsets = FALSE, mergeCategories = FALSE) {
	
	# Fill global variables
	getSelectedSubsets()
	getSelectedCategories()
	generateLegendLabels()
	
	# Make local settings
	x_label = fetch_params$ontologyTerms$time_n0$fullName
	if(mergeSubsets == 'TRUE') {
		mergeSubsets = TRUE
	} else {
		mergeSubsets = FALSE
	}
	if(mergeCategories == 'TRUE') {
		mergeCategories = TRUE
	} else {
		mergeCategories = FALSE
	}
	
	# Subset 1
	getSubsetData(1)
	log <- file("subset_1.log")
	
	# Subset 2
	getSubsetData(2)
	log <- file("subset_2.log")
	
	# Convert TimeMeasurement of the previously defined subsets
	convertDataSetsTimeMeasurement(timeIn, timeOut)
	
	# Generate the different datasets that should be analyised according to settings
	generateDataSets(mergeSubsets, mergeCategories)
	
	# Make survival analysis for all the data_sets
	generateSurvivalData()
	
	# Generate output for visualization
	output <- 	list(
					survival_data = survival_data_sets,
					selected_subsets = selected_subsets,
					selected_categories = selected_categories,
					legend_labels = legend_labels,
					x_label = x_label,
					time_out = timeOut
				)
	
	toJSON(output)
	
}

# Function that extracts the name of the selected Subsets
# Currently not really working
# todo: get selected concepts for generation of subsets
getSelectedSubsets <- function() {
	if(!is.null(loaded_variables$time_n0_s1)) {
		selected_subsets <<- c("Subset 1")
		selected_subsets_count <<- 1
	}
	if(!is.null(loaded_variables$time_n0_s2)) {
		selected_subsets <<- c(selected_subsets, "Subset 2")
		selected_subsets_count <<- selected_subsets_count + 1
	}
}

# Function that extracts the name of the selected Categories
getSelectedCategories <- function() {
	
	if(!is.null(fetch_params$ontologyTerms$category_n0)) {
		selected_categories <<- fetch_params$ontologyTerms$category_n0$fullName
		selected_categories_count <<- 1
	}
	
	if(!is.null(fetch_params$ontologyTerms$category_n1)) {
		selected_categories <<- c(selected_categories, fetch_params$ontologyTerms$category_n1$fullName)
		selected_categories_count <<- selected_categories_count + 1
	}
	
	if(!is.null(fetch_params$ontologyTerms$category_n2)) {
		selected_categories <<- c(selected_categories, fetch_params$ontologyTerms$category_n2$fullName)
		selected_categories_count <<- selected_categories_count + 1
	}
	
	if(!is.null(fetch_params$ontologyTerms$category_n3)) {
		selected_categories <<- c(selected_categories, fetch_params$ontologyTerms$category_n3$fullName)
		selected_categories_count <<- selected_categories_count + 1
	}
	
}

# Function that generates the labels for the legend of the displayed chart
generateLegendLabels <- function() {
	if((length(selected_subsets) > 0) && (length(selected_categories) > 0)) {
		legend_labels <<- as.vector(outer(selected_subsets, selected_categories, paste, sep=" - "))
	} else {
		if(length(selected_categories) == 0) {
			legend_labels <<- selected_subsets
		} else {
			legend_labels <<- selected_categories
		}
	}
}

# Function that gets the data for each subset and returns it as data.frame
getSubsetData <- function(subsetNumber) {
	
	# Subset
	subset <- data.frame()
	
	if(subsetNumber == 1 | subsetNumber == 2) {
	
		# Time (necessary) (max=1)
		if(subsetNumber == 1) {
			time <- loaded_variables$time_n0_s1
			if(nrow(time) == 0) {
				stop(paste("Variable '", fetch_params$ontologyTerms$time_n0$name, "' has no patients for subset ", subsetNumber), sep="")
			}
		} else {
			if(!is.null(loaded_variables$time_n0_s2)) {
				time <- loaded_variables$time_n0_s2
				if(nrow(time) == 0) {
					stop(paste("Variable '", fetch_params$ontologyTerms$time_n0$name, "' has no patients for subset ", subsetNumber), sep="")
				}
			} else {
				time <- data.frame()
			}
		}
		
		if(nrow(time)!=0) {
			
			subset <- time
			
			# Censoring (optional) (max=1)
			if(subsetNumber == 1) {
				if(!is.null(loaded_variables$censoring_n0_s1)) {
					censoring <- loaded_variables$censoring_n0_s1
					censoring[censoring == ""] <- 0
					if(nrow(censoring) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$censoring_n0$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, censoring, by="Row.Label")
					}
				} else {
					#If no event was selected, we consider everyone to have had the event.
					subset <- cbind(subset, 1)
				}
				colnames(subset)[ncol(subset)] <- "CENSOR"
				subset$CENSOR[!(subset$CENSOR=="0")] <- 1
				subset$CENSOR <- as.numeric(subset$CENSOR)
			} else {
				if(!is.null(loaded_variables$censoring_n0_s2)) {
					censoring <- loaded_variables$censoring_n0_s2
					censoring[censoring == ""] <- 0
					if(nrow(censoring) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$censoring_n0$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, censoring, by="Row.Label")
					}
				} else {
					#If no event was selected, we consider everyone to have had the event.
					subset <- cbind(subset, 1)
				}
				colnames(subset)[3] <- "CENSOR"
				subset$CENSOR[!(subset$CENSOR=="0")] <- 1
				subset$CENSOR <- as.numeric(subset$CENSOR)
			}
			
			colnames(subset)[2] <- "TIME"
			
		}
		
	}
	
	if(subsetNumber == 1) {
		subset_1 <<- subset
	}
	
	if(subsetNumber == 2) {
		subset_2 <<- subset
	}
	
}

generateDataSets <- function(mergeSubsets, mergeCategories) {
	
	this_data_set <- data.frame()
	
	# todo: change to !mergeCategories &&
	if(selected_categories_count == 0) {
		# Subset 1
		if(nrow(subset_1) > 0) {
			this_data_set <- cbind(subset_1, 1)
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 2
		if(nrow(subset_2) > 0) {
			this_data_set <- cbind(subset_2, 1)
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
	}
	
	if(mergeCategories && selected_categories_count > 0) {
		# Subset 1
		if(nrow(subset_1) > 0) {
			subset_1_data_set <- subset_1
			# Category 1
			if(!is.null(loaded_variables$category_n0_s1)) {
				category <- loaded_variables$category_n0_s1
				subset_1_data_set <- merge(subset_1_data_set, category, by="Row.Label")
				colnames(subset_1_data_set)[4] <- "CATEGORY_1"
				subset_1_data_set <- subset_1_data_set[,c(1,2,4,3)]
			}
			# Category 2
			if(!is.null(loaded_variables$category_n1_s1)) {
				category <- loaded_variables$category_n1_s1
				subset_1_data_set <- merge(subset_1_data_set, category, by="Row.Label")
				colnames(subset_1_data_set)[5] <- "CATEGORY_2"
				subset_1_data_set <- subset_1_data_set[,c(1,2,3,5,4)]
			}
			# Category 3
			if(!is.null(loaded_variables$category_n2_s1)) {
				category <- loaded_variables$category_n2_s1
				subset_1_data_set <- merge(subset_1_data_set, category, by="Row.Label")
				colnames(subset_1_data_set)[6] <- "CATEGORY_3"
				subset_1_data_set <- subset_1_data_set[,c(1,2,3,4,6,5)]
			}
			# Category 4
			if(!is.null(loaded_variables$category_n3_s1)) {
				category <- loaded_variables$category_n3_s1
				subset_1_data_set <- merge(subset_1_data_set, category, by="Row.Label")
				colnames(subset_1_data_set)[7] <- "CATEGORY_4"
				subset_1_data_set <- subset_1_data_set[,c(1,2,3,4,5,7,6)]
			}
			if(selected_categories_count == 1) {
				subset_1_data_set <- subset_1_data_set[!(is.na(subset_1_data_set$CATEGORY_1) | subset_1_data_set$CATEGORY_1==""),]
			}
			if(selected_categories_count == 2) {
				subset_1_data_set <- subset_1_data_set[!(is.na(subset_1_data_set$CATEGORY_1) | subset_1_data_set$CATEGORY_1=="") | !(is.na(subset_1_data_set$CATEGORY_2) | subset_1_data_set$CATEGORY_2==""),]
			}
			if(selected_categories_count == 3) {
				subset_1_data_set <- subset_1_data_set[!(is.na(subset_1_data_set$CATEGORY_1) | subset_1_data_set$CATEGORY_1=="") | !(is.na(subset_1_data_set$CATEGORY_2) | subset_1_data_set$CATEGORY_2=="") | !(is.na(subset_1_data_set$CATEGORY_3) | subset_1_data_set$CATEGORY_3==""),]
			}
			if(selected_categories_count == 4) {
				subset_1_data_set <- subset_1_data_set[!(is.na(subset_1_data_set$CATEGORY_1) | subset_1_data_set$CATEGORY_1=="") | !(is.na(subset_1_data_set$CATEGORY_2) | subset_1_data_set$CATEGORY_2=="") | !(is.na(subset_1_data_set$CATEGORY_3) | subset_1_data_set$CATEGORY_3=="") | !(is.na(subset_1_data_set$CATEGORY_4) | subset_1_data_set$CATEGORY_4==""),]
			}
			subset_1_data_set <- data.frame(Row.Label=subset_1_data_set$Row.Label, TIME=subset_1_data_set$TIME, CENSOR=subset_1_data_set$CENSOR)
			subset_1_data_set <- cbind(subset_1_data_set, 1)
			colnames(subset_1_data_set)[4] <- "CATEGORY"
			subset_1_data_set <- subset_1_data_set[,c(1,2,4,3)]
			data_sets[[length(data_sets)+1]] <<- subset_1_data_set
		}
		# Subset 2
		if(nrow(subset_2) > 0) {
			subset_2_data_set <- subset_2
			# Category 1
			if(!is.null(loaded_variables$category_n0_s2)) {
				category <- loaded_variables$category_n0_s2
				subset_2_data_set <- merge(subset_2_data_set, category, by="Row.Label")
				colnames(subset_2_data_set)[4] <- "CATEGORY_1"
				subset_2_data_set <- subset_2_data_set[,c(1,2,4,3)]
			}
			# Category 2
			if(!is.null(loaded_variables$category_n1_s2)) {
				category <- loaded_variables$category_n1_s2
				subset_2_data_set <- merge(subset_2_data_set, category, by="Row.Label")
				colnames(subset_2_data_set)[5] <- "CATEGORY_2"
				subset_2_data_set <- subset_2_data_set[,c(1,2,3,5,4)]
			}
			# Category 3
			if(!is.null(loaded_variables$category_n2_s2)) {
				category <- loaded_variables$category_n2_s2
				subset_2_data_set <- merge(subset_2_data_set, category, by="Row.Label")
				colnames(subset_2_data_set)[6] <- "CATEGORY_3"
				subset_2_data_set <- subset_2_data_set[,c(1,2,3,4,6,5)]
			}
			# Category 4
			if(!is.null(loaded_variables$category_n3_s2)) {
				category <- loaded_variables$category_n3_s2
				subset_2_data_set <- merge(subset_2_data_set, category, by="Row.Label")
				colnames(subset_2_data_set)[7] <- "CATEGORY_4"
				subset_2_data_set <- subset_2_data_set[,c(1,2,3,4,5,7,6)]
			}
			if(selected_categories_count == 1) {
				subset_2_data_set <- subset_2_data_set[!(is.na(subset_2_data_set$CATEGORY_1) | subset_2_data_set$CATEGORY_1==""),]
			}
			if(selected_categories_count == 2) {
				subset_2_data_set <- subset_2_data_set[!(is.na(subset_2_data_set$CATEGORY_1) | subset_2_data_set$CATEGORY_1=="") | !(is.na(subset_2_data_set$CATEGORY_2) | subset_2_data_set$CATEGORY_2==""),]
			}
			if(selected_categories_count == 3) {
				subset_2_data_set <- subset_2_data_set[!(is.na(subset_2_data_set$CATEGORY_1) | subset_2_data_set$CATEGORY_1=="") | !(is.na(subset_2_data_set$CATEGORY_2) | subset_2_data_set$CATEGORY_2=="") | !(is.na(subset_2_data_set$CATEGORY_3) | subset_2_data_set$CATEGORY_3==""),]
			}
			if(selected_categories_count == 4) {
				subset_2_data_set <- subset_2_data_set[!(is.na(subset_2_data_set$CATEGORY_1) | subset_2_data_set$CATEGORY_1=="") | !(is.na(subset_2_data_set$CATEGORY_2) | subset_2_data_set$CATEGORY_2=="") | !(is.na(subset_2_data_set$CATEGORY_3) | subset_2_data_set$CATEGORY_3=="") | !(is.na(subset_2_data_set$CATEGORY_4) | subset_2_data_set$CATEGORY_4==""),]
			}
			subset_2_data_set <- data.frame(Row.Label=subset_2_data_set$Row.Label, TIME=subset_2_data_set$TIME, CENSOR=subset_2_data_set$CENSOR)
			subset_2_data_set <- cbind(subset_2_data_set, 1)
			colnames(subset_2_data_set)[4] <- "CATEGORY"
			subset_2_data_set <- subset_2_data_set[,c(1,2,4,3)]
			data_sets[[length(data_sets)+1]] <<- subset_2_data_set
		}
	}
	
	# make data_sets combining subset_data with selected_categories
	if(!mergeCategories && selected_categories_count > 0) {
		# Subset 1 && Category 1
		if(nrow(subset_1) > 0 && !is.null(loaded_variables$category_n0_s1)) {
			category <- loaded_variables$category_n0_s1
			this_data_set <- merge(subset_1, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 1 && Category 2
		if(nrow(subset_1) > 0 && !is.null(loaded_variables$category_n1_s1)) {
			category <- loaded_variables$category_n1_s1
			this_data_set <- merge(subset_1, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 1 && Category 3
		if(nrow(subset_1) > 0 && !is.null(loaded_variables$category_n2_s1)) {
			category <- loaded_variables$category_n2_s1
			this_data_set <- merge(subset_1, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 1 && Category 4
		if(nrow(subset_1) > 0 && !is.null(loaded_variables$category_n3_s1)) {
			category <- loaded_variables$category_n3_s1
			this_data_set <- merge(subset_1, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 2 && Category 1
		if(nrow(subset_2) > 0 && !is.null(loaded_variables$category_n0_s2)) {
			category <- loaded_variables$category_n0_s2
			this_data_set <- merge(subset_2, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 2 && Category 2
		if(nrow(subset_2) > 0 && !is.null(loaded_variables$category_n1_s2)) {
			category <- loaded_variables$category_n1_s2
			this_data_set <- merge(subset_2, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 2 && Category 3
		if(nrow(subset_2) > 0 && !is.null(loaded_variables$category_n2_s2)) {
			category <- loaded_variables$category_n2_s2
			this_data_set <- merge(subset_2, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
		# Subset 2 && Category 4
		if(nrow(subset_2) > 0 && !is.null(loaded_variables$category_n3_s2)) {
			category <- loaded_variables$category_n3_s2
			this_data_set <- merge(subset_2, category, by="Row.Label")
			colnames(this_data_set)[4] <- "CATEGORY"
			this_data_set <- this_data_set[,c(1,2,4,3)]
			this_data_set <- this_data_set[!(is.na(this_data_set$CATEGORY) | this_data_set$CATEGORY==""),]
			data_sets[[length(data_sets)+1]] <<- this_data_set
		}
	}
	
	if(mergeSubsets && selected_subsets_count == 2 && selected_categories_count == 0) {
		data_set_subset_1 <- as.data.frame(data_sets[1])
		data_set_subset_2 <- as.data.frame(data_sets[2])
		merge_data_set <- rbind(data_set_subset_1, data_set_subset_2)
		data_sets <<- list()
		data_sets[[length(data_sets)+1]] <<- merge_data_set
	}
	
	if(mergeSubsets && selected_subsets_count == 2 && selected_categories_count > 0) {
		merged_data_sets <- list()
		for(i in 1:(length(data_sets)/2)) {
			data_set_subset_1 <- as.data.frame(data_sets[i])
			data_set_subset_2 <- as.data.frame(data_sets[i + (length(data_sets) / 2)])
			merge_data_set <- rbind(data_set_subset_1, data_set_subset_2)
			merged_data_sets[[length(merged_data_sets)+1]] <- merge_data_set
		}
		data_sets <<- merged_data_sets
	}

}

convertDataSetsTimeMeasurement <- function(timeIn, timeOut) {
	if(!(timeIn == timeOut)) {
		if(timeIn == "days" && timeOut == "months") {
			convertDataSetsFromDaysToMonths()
		}
		if(timeIn == "days" && timeOut == "years") {
			convertDataSetsFromDaysToYears()
		}
		if(timeIn == "months" && timeOut == "days") {
			convertDataSetsFromMonthsToDays()
		}
		if(timeIn == "months" && timeOut == "years") {
			convertDataSetsFromMonthsToYears()
		}
		if(timeIn == "years" && timeOut == "days") {
			convertDataSetsFromYearsToDays()
		}
		if(timeIn == "years" && timeOut == "months") {
			convertDataSetsFromYearsToMonths()
		}
	}
}

convertDataSetsFromDaysToMonths <- function() {
	# Subset 1
	if(nrow(subset_1) > 0) {
		subset_1$TIME <<- subset_1$TIME / 30
	}
	# Subset 2
	if(nrow(subset_2) > 0) {
		subset_2$TIME <<- subset_2$TIME / 30
	}
}

convertDataSetsFromDaysToYears <- function() {
	# Subset 1
	if(nrow(subset_1) > 0) {
		subset_1$TIME <<- subset_1$TIME / 365
	}
	# Subset 2
	if(nrow(subset_2) > 0) {
		subset_2$TIME <<- subset_2$TIME / 365
	}
}

convertDataSetsFromMonthsToDays <- function() {
	# Subset 1
	if(nrow(subset_1) > 0) {
		subset_1$TIME <<- subset_1$TIME * 30
	}
	# Subset 2
	if(nrow(subset_2) > 0) {
		subset_2$TIME <<- subset_2$TIME * 30
	}
}

convertDataSetsFromMonthsToYears <- function() {
	# Subset 1
	if(nrow(subset_1) > 0) {
		subset_1$TIME <<- subset_1$TIME / 12
	}
	# Subset 2
	if(nrow(subset_2) > 0) {
		subset_2$TIME <<- subset_2$TIME / 12
	}
}

convertDataSetsFromYearsToDays <- function() {
	# Subset 1
	if(nrow(subset_1) > 0) {
		subset_1$TIME <<- subset_1$TIME * 365
	}
	# Subset 2
	if(nrow(subset_2) > 0) {
		subset_2$TIME <<- subset_2$TIME * 365
	}
}

convertDataSetsFromYearsToMonths <- function() {
	# Subset 1
	if(nrow(subset_1) > 0) {
		subset_1$TIME <<- subset_1$TIME * 12
	}
	# Subset 2
	if(nrow(subset_2) > 0) {
		subset_2$TIME <<- subset_2$TIME * 12
	}
}

generateSurvivalData <- function() {
	
	for(data_set in data_sets) {
		survival_fit_data = survfit(Surv(data_set$TIME, data_set$CENSOR)~1)
		survival_data <- data.frame(survival_fit_data$time, survival_fit_data$n.risk, survival_fit_data$n.event)
		colnames(survival_data) <- c("t", "n", "d")
		survival_data_sets[[length(survival_data_sets)+1]] <<- survival_data
	}
	
}