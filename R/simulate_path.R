simulate_path <- function(params, lt) {
  balance <- params$balance_0
  salary  <- params$salary_0
  death_age <- simulate_death_age(params$start_age, lt, params$max_age)

  for (t in 1:(params$max_age - params$start_age)) {
    age <- params$start_age + t
    if (age > death_age || balance <= 0) break

    R <- generate_returns(1, params$mu, params$sigma)
    fees <- params$fee_pct * balance + params$fee_flat

    if (age < params$retire_age) {
      contribution <- params$contrib_rate * salary
      withdrawal <- 0
      salary <- salary * (1 + params$salary_growth)
    } else {
      contribution <- 0
      withdrawal <- params$real_withdrawal
    }

    balance <- (balance - fees + contribution - withdrawal) * R
  }

  return(balance)
}
