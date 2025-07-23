# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' Cross validation to choose the best h_0
#' 
#' @param data Data in matrix form(n * p). Can be the data result from prepare_data
#' @param label Label set. Can be the label result from prepare_data
#' @param grid Grid values of bandwidth h
#' @param num_clust Number of cluster. If not specified, will equal to number of distinct label
#' @param bandwidth Smooth bandwidth
#' @param max_iter Maximum iteration
#' @param min_gap Minimum difference of likelihood
#' @param nrep Number of repetitions
#' @return A list with three elements:
#'           • all_lost – a list contains all the lost at all grid  
#'           • average_lost – average lost at all grid  
#'           • best_h – the best bandwidth
#' @export
cv_functional_clust <- function(data , label , grid = seq(0.1,2.5,0.1), num_clust , max_iter = 1000, min_gap = 0.1, nrep = 10){
  cv_all <- vector("list", length(grid))
  for(i in 1:length(grid)){
    h <- grid[i]
    p <- dim(data)[2]
  
    cv <- rep(0,p)
    for(j in 1:p){
      res <- functional_cluster(data[,-j] ,label = label, num_clust = num_clust , bandwidth = h ,max_iter = max_iter , min_gap = min_gap ,nrep = nrep)
      
      # mu_hat_(-j)(j)
      mu_hat <- res$result$mu %*% gaussian_kernel(seq(1,p,1)[-j],j,h) / sum(gaussian_kernel(seq(1,p,1)[-j],j,h))
      # gamma*y_j
      mu_tru <- t(res$result$resp) %*% as.matrix(data[,j])/colSums(res$result$resp)
      # variance
      sigma_sq_tru <- diag(t(res$result$resp) %*% sweep(matrix(rep(c(data[,j]),8),ncol=8,byrow=FALSE), 2, mu_tru,"-")^2/colSums(res$result$resp))
      # error
      cv[j] <- sum((mu_hat-mu_tru)^2/sigma_sq_tru)
    }
    cv_all[[i]] <- cv
  }
  
  # a list contain number of grids' vectors. Each vector contain number of channels errors.
  return(list(all_lost = cv_all , average_lost = lapply(cv_all,mean), best_h = grid[which.min(lapply(cv_all,mean))]))
}
