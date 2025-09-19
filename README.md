# FSPmix

This package implements a semi-supervised functional clustering model for spatial proteomics data. Our approach is designed for leveraging the small labeled subset to guide learning while extracting structure from the abundant unlabeled data. This makes the method especially useful when full annotation is costly or impractical. 

The main motivating application is a novel subcellular proteome dataset from the model diatom \textit{Thalassiosira pseudonana} (CCMP1335) using differential centrifugation.


## Installation
The R package can be installed using the following commands.
<pre lang="markdown">install.packages("devtools") 
devtools::install_github("ZiyueZHENG/FunctionalClust", subdir = "FunctionalClust")
library(FunctionalClust)
</pre>

## Vignette
### Step 0 Preparing data
This method is designed for data collecting from mass spectorometer. 
The data should be a *n\*(p+1)* dataframe with *n* proteins and *p* fractions and the last column is label. Unlabel data should marked as NA in the last column. 
<table>
  <tr><th>Rowname</th><th>fraction1</th><th>fraction2</th><th>fraction3</th><th>…</th><th>Label</th></tr>
  <tr><th>protiens1</th><td></td><td></td><td></td><td></td><td>Chloroplast</td></tr>
  <tr><th>protiens2</th><td></td><td></td><td></td><td></td><td>Ribosome</td></tr>
  <tr><th>protiens3</th><td></td><td></td><td></td><td></td><td>NA</td></tr>
  <!-- more rows -->
</table>
With this dataframe, you can use *prepare_data* to process the data. And this function will give a list with $data and $labels two attributes which are the direct inputs of main function.
<pre lang="markdown">x <- prepare_data(Loay2024)
data <- x$data
label <- x$labels</pre>
There are several built-in datasets in this package. You can check and refer to their data type:
* yeast2018
* hirst2018
* moloneyTbBSF
* lopitdcU2OS2018
* E14TG2aR
* Loay2024


### Step 1 Fit the model
The main function in this package is *fspmix* which takes at most 7 parameters. **data** and **num_clust** are required, the others are optional. Here is the full list:
* data : A n*p numeric matrix. Row represents protein and column represents fraction. 
* label : A n_c*2 data frame. First column represents the labeled data index, second column represents the label index(numeric factor).  
* num_clust : Number of clusters.(Should be no less than number of label classes)
* bandwidth : Smooth parameter. Default 1
* max_iter : Maximum iteration number. Default 1000
* min_gap : Stopping gap of likelihood. Default 0.1
* nrep : Number of repetitions with different initialization. Default 10
<pre lang="markdown">res <- fspmix(data = data, label = label, 
  num_clust = 10, bandwidth = 1.5, 
  max_iter = 1000, min_gap = 0.1, nrep = 10)
</pre>
In a later section we discussed how to use cross-validation to choose the best hyper-parameters **h** and **num_clust**. 

### Step 2 Interpret the results
The main function *fspmix* will return a list with the following structure:
- result
  - result$mu : A K*d matrix. Each row represents a group mean. Each column represents a fraction.
  - result$sigma : A K*d matrix. The (k,j) element represents the standard deviation of k-th group at j-th fraction.
  - result$rho : A K*1 vector. The porportion of each group.
  - result$resp : A n*K matrix. The (i,k) element represents the probability of i-th protein belong to k-th group.
- likeli_trace : The likelihood trace of algorithm. 
- likelihood : The best likelihood.


### Step 3 Visualization 
*visualize_res* functions in this package allow you to check the clustering results in a 2-dimensional UMAP space.
* data : The same input as *fspmix*
* label : The same input as *fspmix*
* res : The output result from *fspmix*
## Prediction visualization
<pre lang="markdown">visualize_res(data = train_data$data, label = train_data$labels , res = res)
</pre>

## Drawing high probability bands
*draw_hpb* draws the cluster-conditional high proability bands for all fitted clusters including labeled and unlabeled.
* res : Result from *fspmix*
* alpha : Alpha level of bans
* label : label data. Can be NULL(default)
<pre lang="markdown">draw_hpb(res, alpha = 0.05, label = train_data$labels)
</pre>

### Optional: Choosing the best hyper-parameters
Choosing the best smoothern bandwidth:
The *cv_fspmix* is a cross-validation procedure for choosing **h**.

Choosing the best number of clusters:
In the paper we use AIC to choose number of new clusters *K0*. User can choose to use other procedure.


## Authors & Contributors
The contributors are Ziyue Zheng, Loay J. Jabre, Matthew McIlvin, Mak A. Saito, and Sangwon Hyun
