

## Installation
Run the following in the R console:
```{r}
devtools::install_github(“Jseid628/SDmethod")
```

## Python Setup 
1. Install Python 3.11 (recommended) from python.org 
2. Run in R console (replacing the generic path with your own): 
```r
library(SDmethod) 
install_python_deps(python = "/path/to/your/python3.11") 
```
3. Then run simulations: 
```r
run_sim_parallel(rho = 1, n_sim = 100, python_env = "SDmethod_env")
```
