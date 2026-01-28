simulate_death_age <- function(start_age, lt, max_age) {
  idx  <- which(lt@x >= start_age & lt@x <= max_age)
  ages <- lt@x[idx]
  lx   <- lt@lx[idx]
  dx   <- -diff(c(lx, 0))
  qx   <- dx / lx
  sample(ages, size = 1, prob = qx)
}
