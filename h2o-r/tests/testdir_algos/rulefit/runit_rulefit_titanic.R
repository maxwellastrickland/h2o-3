setwd(normalizePath(dirname(R.utils::commandArgs(asValues=TRUE)$"f")))
source("../../../scripts/h2o-r-test-setup.R")



# Test RuleFit on titanic.csv
test.rulefit.titanic <- function() {
    
    Log.info("Importing titanic.csv...\n")
    titanic = h2o.uploadFile(locate("smalldata/gbm_test/titanic.csv"))

    response = "survived"
    predictors <- c("age", "sibsp", "parch", "fare", "sex", "pclass")

    titanic[,response] <- as.factor(titanic[,response])
    titanic[,"pclass"] <- as.factor(titanic[,"pclass"])

    # Split the dataset into train and test
    splits <- h2o.splitFrame(data = titanic, ratios = .8, seed = 1234)
    train <- splits[[1]]
    test <- splits[[2]]

    rfit <- h2o.rulefit(y = response, x = predictors, training_frame = train, min_rule_length = 1, max_rule_length = 10, max_num_rules = 100, seed = 1, model_type="rules")

    print(rfit@model$rule_importance)

    h2o.predict(rfit, newdata = test)

    expect_that(h2o.auc(h2o.performance(rfit)), equals(h2o.auc(h2o.performance(rfit, newdata =  train))))
    expect_that(h2o.logloss(h2o.performance(rfit)), equals(h2o.logloss(h2o.performance(rfit, newdata =  train))))
  
}

doTest("RuleFit Test: Titanic Data", test.rulefit.titanic)
