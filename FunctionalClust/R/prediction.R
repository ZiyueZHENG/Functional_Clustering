# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' Make prediction on result$resp
#' @param resp The n*K memebership matrix generate from functional_cluster. It is in res$result$resp
#' @return A dataframe with the first column is predictive label and the second colunm is proability
#' @export
prediction <- function(res){
  pred <- data.frame(t(apply(res$result$resp, 1, function(p) {
    k <- sample.int(length(p), size = 1, prob = p)
    c(predict_label = k, prob = p[k])})))
  return(pred)
}
