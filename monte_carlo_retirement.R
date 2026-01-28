###################################################################
# Monte Carlo Retirement Account Simulation#
# Author: Aram Park
# Description: Stochastic simulation of retirement account balances
# using life tables, lognormal returns, and sensitivity analysis
###################################################################

# 0. Load required libraries
library(lifecontingencies)
library(ggplot2)

# 1. Parameters
params <- list(
  n_sim = 10000, # Number of simulations
  start_age = 30, 
  retire_age = 65,
  max_age = 110,
  
  mu = 0.05,    # log of expected gross real return
  sigma = 0.15, # Volatility
  infl = 0.02,  # Inflation for records only
  
  salary_0 = 70000,     # Initial salary
  salary_growth = 0.01, # Real growth
  contrib_rate = 0.1,   # Contribution rate
  
  real_withdrawal = 40000, # Fixed real income target, retirement withdrawal
  
  # Fees
  fee_pct  = 0.005, # 0.5% of balance
  fee_flat = 300,   # Flat annual fee
  
  balance_0 = 50000 # Initial balance
)

set.seed(123) # Initialize the pseudo-random numbers


# 2. Life table
data("soa08Act") # SOA 2008 Annuity table
lt <- new("lifetable", x = soa08Act@x, lx = soa08Act@lx, name = "SOA 2008 Annuity Table")


# 3. Functions

# 3a. Simulation of death age based on the life table
simulate_death_age <- function(start_age, lt, max_age) {
  idx  <- which(lt@x >= start_age & lt@x <= max_age)
  ages <- lt@x[idx]     # The vector of ages  
  lx   <- lt@lx[idx]      # The number of survivors at each age x
  dx   <- -diff(c(lx,0)) 
  qx   <- dx/lx
  sample(ages, size =1, prob = qx)
}

# 3b. Generate lognormal returns
generate_returns <- function(n, mu, sigma) {
  exp((mu-0.5*sigma^2) + sigma * rnorm(n))
}
# Replace with direct use of rlnorm()
# R <- rlnorm(
#  1,
#  meanlog = param$mu - 0.5 * params$sigma^2,
#  sdlog = params$sigma)

# 3c. Simulate a single account path
simulate_path <- function(params, lt){
  balance   <- params$balance_0
  salary    <- params$salary_0
  death_age <- simulate_death_age(params$start_age, lt, params$max_age)
  
  ruined    <- FALSE # Indicator of financial ruin
  ruin_age  <- NA  # Age at which ruin occurs
  
  for (t in 1:(params$max_age - params$start_age)){
    age <- params$start_age + t # Convert time index into attained age
    if (age > death_age || balance <= 0) break # Two stopping events: death, ruin
    # Investment return
    R <- generate_returns(1, params$mu, params$sigma) # Draws one stochastic real annual return. (i.i.d returns, No regime switching, no correlation with mortality or salary growth)
    # Fees
    fees <- params$fee_pct * balance + params$fee_flat # Fee drag
    
    # Cash flow logic: pre-retirement vs post-retirement
    if (age < params$retire_age) {
      contribution <- params$contrib_rate * salary
      withdrawal <- 0
      salary <- salary * (1 + params$salary_growth) # Salary grows deterministically (salary risk ignored)
    } else {
      contribution <- 0
      withdrawal <- params$real_withdrawal # Fixed real withdrawal each year, constant real spending
    }
    
    # Update balance
    balance <- (balance - fees + contribution - withdrawal) * R # Financial recursion of the model (Assumptions: contributions are invested immediately, withdrawal are taken immediately, fees are charged upfront, returns are earned on the net invested balance)
    
    if (balance <= 0 && !ruined) {
      ruined   <- TRUE
      ruin_age <- age
      balance  <- 0
      break
    }
   }
  list(
    terminal_balance = balance,
    ruined = ruined,
    ruin_age = ruin_age,
    death_age = death_age
  )
}

# 3d. Run sensitivity scenario
run_sensitivity <- function(param_name, new_val, params, lt, n_sim = 10000){
  params_copy <- params
  params_copy[[param_name]] <- new_val
  
  sims <- replicate(n_sim, simulate_path(params_copy, lt),simplify = FALSE)
  ruined_flag <- sapply(sims, "[[", "ruined") # Extract ruin indicator
  
  mean(ruined_flag)
}
  
# 4. Main Monte Carlo Simulation
run_monte_carlo <- function(params, lt) {
  results <- replicate(params$n_sim, simulate_path(params, lt), simplify = FALSE)
  
  terminal_balance  <- sapply(results, '[[', "terminal_balance")
  ruined_flag       <- sapply(results, '[[', "ruined")
  ruin_age          <- sapply(results, '[[', "ruin_age")
  death_age         <- sapply(results, '[[', "death_age")
  # Risk metrics
  prob_ruin <- mean(ruined_flag)
  VaR_5     <- quantile(terminal_balance, 0.05)                   # The 5% Value at Risk is the 5th percentile of the terminal balance distribution.
  TVaR_5    <- mean(terminal_balance[terminal_balance <= VaR_5]) # The average terminal balance in the worst 5% of scenarios, captures tail severity.
  
  list(
    results = results,
    terminal_balance = terminal_balance,
    ruined_flag = ruined_flag,
    ruin_age = ruin_age,
    death_age = death_age,
    prob_ruin = prob_ruin,
    VaR_5 = VaR_5,
    TVaR_5 = TVaR_5
  )
}

# 5. Run simulation
mc_output <- run_monte_carlo(params, lt)
# Probability of ruin
mc_output$prob_ruin
mc_output$VaR_5
mc_output$TVaR_5

# 6. Probability of ruin by age
ages <- params$retire_age:params$max_age
ruin_by_age <- sapply(ages, function(a) {
  mean(mc_output$ruin_age <=a, na.rm = TRUE) 
})

plot(
  ages, ruin_by_age, type = "l",
  xlab = "Age", ylab = "Probability of Ruin",
  main = "Probability of Ruin by age"
)

# 7. Sensitivity Analysis
sens_results <- data.frame(
  Scenario = c("Base Case", "High Vol(+5%)", "Low Return (-1%)", "High Withdrawal (+10k)", "Higher Fees (1%)"),
  Prob_Ruin = c(
    mc_output$prob_ruin,
    run_sensitivity("sigma", params$sigma + 0.05, params, lt, params$n_sim),
    run_sensitivity("mu", params$mu-0.01, params, lt, params$n_sim),
    run_sensitivity("real_withdrawal", params$real_withdrawal + 10000, params, lt, params$n_sim),
    run_sensitivity("fee_pct", params$fee_pct+0.005, params, lt, params$n_sim)
  )
)

ggplot(sens_results, aes(x=reorder(Scenario, Prob_Ruin), y = Prob_Ruin)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "Sensitivity Analaysis : Probability of Ruin",
       x = "Stress Scenario", y = "P(Ruin)") +
  theme_classic()


  
