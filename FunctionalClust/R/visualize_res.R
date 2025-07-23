# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' 
#' @param data Data
#' @param label Label
#' @param prediction Generate from prediction function 
#' @export
visualize_res <- function(data,label,res){
  pred <- prediction(res)
  
  d.umap <- umap::umap(data,n_neighbors = 500, min_dist = 0.05, 
                 verbose = T, n_epochs = 1000, n_components=2)
  scores <- data.frame(d.umap$layout)
  
  colnames(scores) <- c("x1","x2")
  data = data %>% 
    cbind(scores) %>%
    cbind(pred)
  
  new_group <- paste0( "New", seq_len( length(unique(pred$predict_label)) - length(unique(label[,2])) ) ) 
  levels <- c(attr(label$label, "levels"), new_group)
  
  p1 <- data %>% ggplot() +
  geom_point(data = data[-label[,1],], # unlabeled
             aes(x = x1, y = x2), size=1, alpha = 0.1) +
  geom_point(data = data[label[,1],], # labeled
             aes(x = x1, y = x2, col = levels[label[,2]] ), size=1.5, alpha = 0.8) +
  theme_classic() +
  theme(legend.title = element_blank(),
        plot.subtitle = element_text(hjust = 0.5),
        panel.grid.major = element_line(color = "gray88", size = 0.2)
        ) +
  labs(subtitle = "Annotated data set")
  
  p2 <- data %>% 
  ggplot() +
  geom_point(aes(x = x1, y = x2, col = levels[predict_label], size = prob) , alpha = .8) +
  scale_size(range = c(0.01, 1.5)) +
  labs(color = "", size = "Probability") +
  theme_classic() +
  theme(plot.subtitle = element_text(hjust = 0.5),
        legend.spacing.y = unit(0.05, 'cm'),
        legend.margin = margin(0, 0, 0, 0),
        panel.grid.major = element_line(color = "gray88", size = 0.2)
        ) +
  labs(subtitle = "Predictive groups")
  
  p1 / p2
}
