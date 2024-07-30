
# Final Project API File - Natalie Root

# Load necessary libraries
library(dplyr)
library(tidyr)
library(readr)
library(ggplot2)
library(httr)
library(jsonlite)
library(knitr)
library(rpart)
library(GGally)
library(randomForest, lib.loc="C:/Users/natal/Desktop/R_packages")
library(gbm, lib.loc="C:/Users/natal/Desktop/R_packages")
library(caret, lib.loc="C:/Users/natal/Desktop/R_packages")

# Set a seed in order to make things reproducible
set.seed(14)

# Import the data
diabetes_data <- read.csv("diabetes_binary_health_indicators_BRFSS2015.csv")

# Ensure NoDocbcCost is a factor with valid level names
levels(diabetes_data$NoDocbcCost) <- make.names(levels(diabetes_data$NoDocbcCost))

# Split the data into training and testing sets (70% train, 30% test)
train_index <- createDataPartition(diabetes_data$NoDocbcCost, p = 0.7, list = FALSE)

train_data <- diabetes_data[train_index, ]
test_data <- diabetes_data[-train_index, ]

# Fit the model that we identified as the best model in the 'Modeling' file
control <- trainControl(method = "cv", number = 5, summaryFunction = mnLogLoss, classProbs = TRUE)
rfGrid <- expand.grid(mtry = c(1, 2, 3))
rfModel <- train(NoDocbcCost ~ ., data = train_data, method = "rf", trControl = control, tuneGrid = rfGrid)

# Define default values for predictors
default_values <- sapply(train_data, function(col) {
  if (is.numeric(col)) {
    return(mean(col, na.rm = TRUE))
  } else if (is.factor(col)) {
    return(as.character(names(which.max(table(col)))))
  }
})

#* @apiTitle Best Model API

#* Predict endpoint
#* @param Age
#* @param Income
#* ...
#* @get /pred
function(...) {
  input <- list(...)
  for (name in names(input)) {
    if (input[[name]] == "") {
      input[[name]] <- default_values[[name]]
    }
  }
  input <- as.data.frame(t(unlist(input)))
  colnames(input) <- names(default_values)
  pred <- predict(rfModel, newdata = input, type = "prob")
  return(pred)
}

#* Info endpoint
#* @get /info
function() {
  list(
    name = "Natalie Root",
    url = "Github pages link"
  )
}

# API example function call 1
#curl "http://localhost:8000/pred"

# API example function call 2
#curl "http://localhost:8000/pred?Age=4&Income=6"

# API example function call 3
#curl "http://localhost:8000/pred?Age=4"

# Run the API with plumber
r <- plumb("C:\Users\natal\Desktop\NCSU\summer 24\ST558\Repos\FinalProject\API.R")
r$run(port = 8000)
