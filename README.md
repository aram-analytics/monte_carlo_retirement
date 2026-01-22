# Monte Carlo Retirement Account Simulation

## Overview
This project implements a **stochastic Monte Carlo simulation** for an individual retirement account, assessing the risk of **financial ruin** over a lifetime. The simulation accounts for:

- Stochastic investment returns (lognormal distribution)
- Salary growth and contributions
- Fixed real withdrawals during retirement
- Investment fees (percentage and flat)
- Longevity risk using a life table (SOA 2008 Actuarial Table)
- Risk metrics such as **Probability of Ruin**, **VaR**, and **TVaR**
- Sensitivity analysis under stressed economic scenarios

---

## Features

1. **Single-path simulation** of account balances from a starting age to a maximum age.
2. **Monte Carlo simulation** over `n_sim` paths.
3. **Ruin analysis**:
   - Probability of ruin
   - Ruin age distribution
   - Terminal balance metrics (VaR, TVaR)
4. **Sensitivity analysis**:
   - High volatility
   - Low expected returns
   - Higher withdrawals
   - Increased fees
5. **Visualizations**:
   - Probability of ruin by age
   - Sensitivity analysis bar chart

---

## Requirements

- R >= 4.2
- Packages:
  - `lifecontingencies`
  - `ggplot2`

Install missing packages with:

```r
install.packages(c("lifecontingencies", "ggplot2"))
