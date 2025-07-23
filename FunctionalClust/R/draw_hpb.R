# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' 
#' @param res Output from functional_cluster
#' @param alpha Alpha level, default is 0.05
#' @param label Label set, used to assign graph titles. Can be empty(default)
#' 
#' @export
draw_hpb <- function(res, alpha = 0.05,label = NULL){
  K <- nrow(res$result$mu)
  p <- ncol(res$result$mu)
  
  if(!is.null(label)){
    group <- attr(label$label,"levels")
    if(K>length(group)){
      group <- c(group,paste0("New", 1: (K - length(group))))
    }
  }else{
    group <- paste0("Group",1:K)
  }
  
  for(i in 1:K){
    mean_line <- res$result$mu[i,]
    var_all <- res$result$sigma[i,]
    x <- seq(1,p)
    par(mgp = c(3, 0.5, 0)) 
    plot(x, t(mean_line), type = "l", ylim = c(0,1),lty = 1, lwd = 2, pch = 20, col = i,
         xlab = "", ylab = "",main = group[i])
    upper <- mean_line + qnorm(1 - (1-(1-alpha)^(1/11))/2,0,1) * var_all
    lower <- mean_line - qnorm(1 - (1-(1-alpha)^(1/11))/2,0,1) * var_all
    polygon(c(x, rev(x)), c(upper, rev(lower)), col = adjustcolor(i, alpha.f = 0.2), border = NA)
    
  }
}
