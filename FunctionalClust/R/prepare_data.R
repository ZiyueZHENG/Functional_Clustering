# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' Split a data frame into a data-matrix and indexed label table
#'
#' @param df A data.frame with (n + 1) columns:
#'           the first n are numeric predictors,
#'           the last column is a (possibly-NA) character/ factor label.
#' @return   A list with two elements:
#'           • data   – an n-column numeric matrix  
#'           • labels – a data.frame with  
#'               - index  : row numbers of the non-NA labels  
#'               - label  : integer codes (factor levels) of those labels
#' @export
prepare_data <- function(df) {
  stopifnot(is.data.frame(df), ncol(df) >= 2)

  ## predictors → numeric matrix  (drop = FALSE keeps matrix form for n = 1)
  X <- as.matrix(df[, -ncol(df), drop = FALSE])

  ## labels  → (index, integer-factor)
  y        <- df[[ncol(df)]]
  y[y == "unknown"] <- NA
  idx      <- which(!is.na(y))           # rows that *have* a label
  y_factor <- factor(y[idx])             # gives reproducible level ordering
  y_int    <- as.integer(y_factor)       # integer codes 1, 2, …

  labels <- data.frame(index = idx,
                       label = y_int)

  ## keep the mapping so you can recover the original text
  attr(labels$label, "levels") <- levels(y_factor)

  list(data = X,
       labels = labels)
}

