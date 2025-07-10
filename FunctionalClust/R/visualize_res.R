# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' 
#' @param data
#' @param res Results generated from functional_cluster()
#' @param method Can only be one the dimension reduction method: "PCA", "UMAP", "tSNE"
#' 
#' 
visualize_res <- function(data,label,method,res){
  if(method == "PCA"){
    # PCA
    pca <- data %>%
    stat::prcomp()
    pr = pca$x %>% .[,1:2]
    data = data %>% 
    cbind(pr)
  }else if(method == "UMAP"){
    # UMAP
    d.umap <- umap::umap(data,n_neighbors = 500, min_dist = 0.05, 
                 verbose = T, n_epochs = 1000, n_components=2)
    umap_scores <- data.frame(d.umap$layout)
    data = data %>% 
    cbind(umap_scores)
  }else if(method == "tSNE"){
    #tSNE
    tsne_score <- Rtsne::Rtsne(data)
    data = data %>% 
    cbind(umap_scores)
  }else{
    print("Method is invalid. Please use one of PCA, UMAP or tSNE")
  }
  
  
  
  
  
}
