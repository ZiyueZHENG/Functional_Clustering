# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' Main function of semi-supervised functional clustering
#' 
#' @param data Data in matrix form(n * p). Can be the data result from prepare_data
#' @param label Label set. Can be the label result from prepare_data
#' @param num_clust Number of cluster. If not specified, will equal to number of distinct label
#' @param bandwidth Smooth bandwidth
#' @param max_iter Maximum iteration
#' @param min_gap Minimum difference of likelihood
#' @param nrep Number of repetitions
#' @return A list with three elements:
#'           • data   – an n-column numeric matrix  
#'           • labels – a data.frame with  
#'               - index  : row numbers of the non-NA labels  
#'               - label  : integer codes (factor levels) of those labels  
#' @export
functional_cluster <- function(data , label = NULL , num_clust ,
                               bandwidth = 1, max_iter = 1000 ,
                               min_gap   = 1 , nrep      = 5) {
  n  <- nrow(data)
  p  <- ncol(data)
  K  <- num_clust
  data_matrix <- as.matrix(data)
  
  ## pre-compute Gaussian kernel over column indices (1:p)
  t_index <- seq_len(p)
  kernel_gauss <- exp(-outer(t_index, t_index, "-")^2 / (2 * bandwidth^2)) 
  
  ## identity kernel for the variance (0-1 kernel)
  kernel_id <- diag(p)                          #  p × p
  
  likeli_all <- vector("list", nrep)
  result     <- vector("list", nrep)
  
  for (r in seq_len(nrep)) {
    loglikeli_total <- numeric(max_iter)
    resp  <- gtools::rdirichlet(n, rep(1, K))     #  n × K
    rho   <- colSums(resp)/sum(resp)  #  K
    mu    <- matrix(0,  K, p)                     #  K × p
    sigma <- matrix(0.1, K, p)                    #  K × p
    
    if (!is.null(label)) {
      for (lab in unique(label$label)) {
        rows <- label[label$label == lab, ]$index
        mu[lab, ]    <- colMeans(data_matrix[rows, , drop = FALSE])
        sigma[lab, ] <- apply(data_matrix[rows, , drop = FALSE], 2, sd)
      }
    }
    # randomise the remaining components (if any)
    unfilled <- setdiff(seq_len(K), unique(label$label))
    for (i in unfilled) {
      rand <- sample(setdiff(1:n,label$index),10)
      mu[i, ]    <- colMeans(data_matrix[rand, , drop = FALSE])
      sigma[i, ] <- apply(data_matrix[rand, , drop = FALSE], 2, sd)
    }

    for (iter in seq_len(max_iter)) {
      log_resp <- matrix(0, n, K) # n × K
      
      #### E step ####
      for (k in seq_len(K)) {
        # n × p matrix of log-densities for component k
        log_dens_k <- dnorm(data_matrix,
                            mean = matrix(mu[k, ], nrow = n, ncol = p, byrow = TRUE),
                            sd   = matrix(sigma[k, ], nrow = n, ncol = p, byrow = TRUE),
                            log  = TRUE)
        log_resp[ , k] <- log(rho[k]) + rowSums(log_dens_k)
      }
      resp <- row_softmax(log_resp) # n × K
      
      if (!is.null(label)) {
        anchored <- label$index
        classes  <- label$label
        resp[cbind(anchored, matrix(rep(seq_len(K), each = length(anchored)), ncol = K))] <- 0
        resp[cbind(anchored, classes)] <- 1
      }
      
      
      #### M step ####
      rho <- pmax(colMeans(resp), 1e-10) # K, pmax avoid log(0)
      
      for (k in seq_len(K)) {
        w_k           <- resp[ , k]                # n
        w_sum         <- sum(w_k) + 1e-8  # 1 × p
        numer_mu      <- (t(w_k) %*% data_matrix) %*% kernel_gauss
        denom         <- w_sum * colSums(kernel_gauss)
        mu[k, ]       <- numer_mu / pmax(denom, 1e-2)
      }
      
      for (k in seq_len(K)) {
        centered      <- sweep(data_matrix, 2, mu[k, ], "-")  # n × p
        numer_sig     <- colSums(resp[ , k] * centered^2)
        sigma[k, ]    <- sqrt(pmax(numer_sig / pmax(colSums(resp)[k], 1e-2), 1e-5))
      }
      
      loglikeli_total[iter] <- sum(rowSums(resp * (log_resp - log(pmax(resp, 1e-10)))))
      

      if (iter > 1 && abs(loglikeli_total[iter] - loglikeli_total[iter - 1]) < min_gap){
        break
      }
    }
    
    likeli_all[[r]] <- loglikeli_total[seq_len(iter)]
    result[[r]]     <- list(mu = mu, sigma = sigma, rho = rho, resp = resp)
  }
  
  best_time <- which.max(sapply(likeli_all, max, na.rm = TRUE))
  likeli_trace = likeli_all[[best_time]]
  
  list(likeli_trace = likeli_trace,
       result       = result[[best_time]],
       likelihood   = likeli_trace[length(likeli_trace)])
}


