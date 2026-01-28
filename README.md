# Monte Carlo Retirement Account Simulation

## 1. Overview

This project implements a **stochastic Monte Carlo simulation model** to assess the risk of **retirement account ruin** over an individual’s lifetime. The model integrates **investment risk, longevity risk, contribution dynamics, withdrawals, and fees** within a unified actuarial framework.

The primary objective is to estimate the **probability and timing of financial ruin** prior to death and to evaluate the distribution of terminal account balances under both base-case and stressed economic scenarios.

---

## 2. Modelling Framework

The model simulates the evolution of an individual retirement account from a specified starting age until death or a maximum modelling age, whichever occurs first.

Each simulation path incorporates:

- Stochastic real investment returns  
- Real salary growth and contribution flows  
- Deterministic real retirement withdrawals  
- Investment management fees (percentage-based and flat)  
- Mortality risk based on a standard actuarial life table  

The simulation is repeated across a large number of paths to obtain empirical distributions of outcomes.

---

## 3. Key Assumptions

### 3.1 Investment Returns

- Annual real investment returns follow a **lognormal distribution**.  
- Returns are generated as:

$$
R = \exp\left(\mu - \frac{1}{2} \sigma^2 + \sigma Z\right), \quad Z \sim \mathcal{N}(0,1)
$$

- Under this parameterisation:

$$
\mathbb{E}[R] = \exp(\mu)
$$

This formulation ensures that the parameter $\mu$ directly represents the **log of the expected gross real return**.

---

### 3.2 Salary, Contributions, and Withdrawals

- Salary growth and contributions are modelled in **real terms**.  
- Contributions are a fixed proportion of salary during the accumulation phase.  
- Withdrawals during retirement are fixed real amounts and occur annually.

---

### 3.3 Fees

- Investment fees consist of:  
  - A proportional fee applied to account balances  
  - A flat annual fee  
- Fees are deducted annually **before return realisation**.

---

### 3.4 Mortality

- Mortality is modelled using the **SOA 2008 Annuity Life Table**, implemented via the `lifecontingencies` R package.
- The use of a gender-neutral annuity life table implicitly assumes identical mortality experience across genders. This may understate or overstate longevity risk for specific subpopulations.
- Death age is simulated probabilistically using the life table survival distribution.  
- Mortality is assumed independent of investment performance.  

---

### 3.5 Definition of Ruin

- **Ruin** occurs when the account balance becomes **non-positive** at any time prior to death, after scheduled withdrawals and fees.  
- Once ruin occurs, the account balance is set to zero and remains there for the remainder of the simulation path.

---

## 4. Simulation Structure

### 4.1 Single-Path Simulation

A single simulation path tracks:

1. Age progression  
2. Salary growth and contributions  
3. Investment returns and fees  
4. Retirement withdrawals  
5. Mortality and ruin checks  

This produces a full life-cycle trajectory of account balances for one individual.

---

### 4.2 Monte Carlo Simulation

- The single-path model is repeated over `n_sim` independent simulation paths.  
- Outcomes are aggregated to estimate probabilities and risk measures.

---

## 5. Outputs and Risk Metrics

### 5.1 Ruin Analysis

- Probability of ruin before death  
- Distribution of ruin ages (conditional on ruin occurring)  
- Cumulative probability of ruin by age  

---

### 5.2 Terminal Wealth Metrics

- Distribution of terminal account balances at death  
- Value at Risk (VaR)  
- Tail Value at Risk (TVaR)  

These metrics quantify downside financial risk in retirement outcomes.

---

## 6. Sensitivity Analysis

Sensitivity analysis is conducted to assess the robustness of results to adverse conditions. Each scenario modifies **one parameter at a time** relative to the base case.

Scenarios include:

- Increased investment volatility  
- Lower expected real returns  
- Higher real retirement withdrawals  
- Increased investment fees  

Results are compared to the base case to identify key drivers of ruin risk.

---

## 7. Visualisation

The project includes graphical outputs to support interpretation, including:

- Probability of ruin by age  
- Comparative bar charts for sensitivity scenarios  

---

## 8. Installation and Usage

### 8.1 Requirements

- R >= 4.2
- Packages:
  - `lifecontingencies`
  - `ggplot2`

Install missing packages with:
```bash
install.packages(c("lifecontingencies", "ggplot2")) evaluate
```

### 8.2 Clone the Repository

```bash
git clone https://github.com/aram-analytics/monte_carlo_retirement.git
```

### 8.3 Running the Simulation
```bash
source("monte_carlo_retirement.R")
```

## 9. Limitations

This model is intentionally simplified and subject to several limitations:

- Asset allocation is fixed and does not adjust dynamically over time
- Inflation is assumed deterministic via real-term modelling
- Withdrawals follow a fixed rule and do not respond to account performance
- No bequest motive or behavioural response is modelled
- Mortality improvements are not incorporated
- These limitations provide clear avenues for future extension.

## 10. Intended Use

This project is designed for:

- Educational and demonstration purposes
- Actuarial risk analysis and retirement modelling practice
- Portfolio presentation for actuarial or quantitative finance roles
- It is not intended for real-world financial advice or regulatory decision-making.




