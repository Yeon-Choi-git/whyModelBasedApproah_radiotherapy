# Estimate odds ratio from binary outcome vectors
get_or <- function(outcome_RT, outcome_PT){
  stopifnot("Lengths of the photon (RT) and proton (PT) outcome should be equal." 
            = length(outcome_RT) == length(outcome_PT))
  risk_RT <- sum(outcome_RT)/length(outcome_RT)
  risk_PT <- sum(outcome_PT)/length(outcome_PT)
  return((risk_PT/(1-risk_PT))/ ((risk_RT)/(1-risk_RT)))
}
