# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' Row normalized a matrix with sum up to one
#' @param log_mat
row_softmax <- function(log_mat) {
  row_max <- apply(log_mat, 1, max)
  exp(log_mat - row_max) / rowSums(exp(log_mat - row_max))
}

