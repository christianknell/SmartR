# Load libraries
library(survival)

# Global variables
dummyCategory <- "NO_CATEGORY_SELECTED"
selectedCategoryCount <- 0
selected_categories <- c("")

# MAIN function which is called by SmartR automatically
main <- function(legendPosition = "Right") {
	
	log <- file("survivalRscript.log")
	
	write.table(loaded_variables, log, row.names=FALSE, append=TRUE, sep="\t")
	
	getSelectedCategories()
	
	xLabel = fetch_params$ontologyTerms$time_n0$fullName
	
	# Subset 1
	subset_1 <- getSubsetData(1)
	survival_fit_data_1 = survfit(Surv(subset_1$TIME, subset_1$CENSOR)~1)
	survival_data_1 <- data.frame(survival_fit_data_1$time, survival_fit_data_1$n.risk, survival_fit_data_1$n.event)
	colnames(survival_data_1) <- c("t", "n", "d")
	
	# Subset 2
	subset_2 <- getSubsetData(2)
	if(nrow(subset_2) > 0) {
		survival_fit_data_2 = survfit(Surv(subset_2$TIME, subset_2$CENSOR)~1)
		survival_data_2 <- data.frame(survival_fit_data_2$time, survival_fit_data_2$n.risk, survival_fit_data_2$n.event)
		colnames(survival_data_2) <- c("t", "n", "d")
	} else {
		survival_data_2 <- data.frame()
	}
	
	if(nrow(survival_data_2) > 0) {
		survival_data <- rbind(as.matrix(survival_data_1), as.matrix(survival_data_2))
	} else {
		survival_data <- survival_data_1
	}
	
	output <- 	list(
					survival_data = survival_data,
					selected_categories = selected_categories,
					selectedCategoryCount = selectedCategoryCount,
					xLabel = xLabel,
					maxTime = 300
				)
	
	toJSON(output)
	
}

# Function that extracts the name of the selected Categories
getSelectedCategories <- function() {
	
	if(!is.null(loaded_variables$category_n0)) {
		selected_categories <<- fetch_params$ontologyTerms$category_n0$fullName
		selectedCategoryCount <<- 1
	}
	
	if(!is.null(loaded_variables$category_n1)) {
		selected_categories <<- c(selected_categories, fetch_params$ontologyTerms$category_n1$fullName)
		selectedCategoryCount <<- selectedCategoryCount + 1
	}
	
	if(!is.null(loaded_variables$category_n2)) {
		selected_categories <<- c(selected_categories, fetch_params$ontologyTerms$category_n2$fullName)
		selectedCategoryCount <<- selectedCategoryCount + 1
	}
	
	if(!is.null(loaded_variables$category_n3)) {
		selected_categories <<- c(selected_categories, fetch_params$ontologyTerms$category_n3$fullName)
		selectedCategoryCount <<- selectedCategoryCount + 1
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
			
			# Category (optional) (max=4)
			if(subsetNumber == 1) {
				if(!is.null(loaded_variables$category_n0_s1)) {
					category <- loaded_variables$category_n0_s1
					selectedCategoryCount <<- 1
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n0$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				} else {
					# If no category was selected, everyone is put in the same category.
					subset <- cbind(subset, dummyCategory)
				}
				if(!is.null(loaded_variables$category_n1_s1)) {
					category <- loaded_variables$category_n1_s1
					selectedCategoryCount <<- 2
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n1$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				}
				if(!is.null(loaded_variables$category_n2_s1)) {
					category <- loaded_variables$category_n2_s1
					selectedCategoryCount <<- 3
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n2$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				}
				if(!is.null(loaded_variables$category_n3_s1)) {
					category <- loaded_variables$category_n3_s1
					selectedCategoryCount <<- 4
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n3$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				}
			} else {
				if(!is.null(loaded_variables$category_n0_s2)) {
					category <- loaded_variables$category_n0_s2
					selectedCategoryCount <<- 1
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n0$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				} else {
					#If no category was selected, everyone is put in the same category.
					subset <- cbind(subset, dummyCategory)
				}
				if(!is.null(loaded_variables$category_n1_s2)) {
					category <- loaded_variables$category_n1_s2
					selectedCategoryCount <<- 2
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n1$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				}
				if(!is.null(loaded_variables$category_n2_s2)) {
					category <- loaded_variables$category_n2_s2
					selectedCategoryCount <<- 3
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n2$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				}
				if(!is.null(loaded_variables$category_n3_s2)) {
					category <- loaded_variables$category_n3_s2
					selectedCategoryCount <<- 4
					if(nrow(category) == 0) {
						stop(paste("Variable '", fetch_params$ontologyTerms$category_n3$name, "' has no patients for subset ", subsetNumber), sep="")
					} else {
						subset <- merge(subset, category, by="Row.Label")
					}
				}
			}
			
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
				colnames(subset)[ncol(subset)] <- "CENSOR"
			}
			
			colnames(subset)[1] <- "TIME"
			
		}
		
	}
	
	return(subset)
	
}