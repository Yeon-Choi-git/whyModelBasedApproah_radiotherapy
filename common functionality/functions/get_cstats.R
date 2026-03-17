# get C-index
get_cstats <- function(model = NULL, 
                       newdata,
                       observed_outcome,
                       predicted_prob = NULL){
  
  stopifnot(
    "At least one argument should be given either for 'model' or 'predicted_prob'"= 
      !all(is.null(model), is.null(predicted_prob))
  )
  
  true_res <- newdata[[observed_outcome]] # true binary outcome
  
  test_res <- if(!is.null(predicted_prob)){
    newdata[[predicted_prob]] # predicted ntcp from the full model
  } else {
    predict(model, newdata = newdata, type = "response")
  }
  return(as.numeric(suppressMessages(pROC::auc(true_res, test_res))))
}

