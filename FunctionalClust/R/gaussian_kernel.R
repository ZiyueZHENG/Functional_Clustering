# Generated from create-FunctionalClust.Rmd: do not edit by hand

#' Row normalized a matrix with sum up to one
#' @param x
#' @param x_prime
#' @param sigma
gaussian_kernel <- function(x, x_prime, sigma = bandwidth) {
    exp(-((x - x_prime)^2) / (2 * sigma^2))
}
