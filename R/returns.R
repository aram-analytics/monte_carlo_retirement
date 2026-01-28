generate_returns <- function(n, mu, sigma) {
  exp((mu - 0.5 * sigma^2) + sigma * rnorm(n))
}
