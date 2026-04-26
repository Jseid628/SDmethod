


## Python Setup 
1. Install Python 3.11 (recommended) from python.org 
2. Run in R: 
```r
library(SDmethod) 
install_python_deps(python = "/path/to/your/python3.11") 
```
3. Then run simulations: 
```r
run_sim_parallel(rho = 1, n_sim = 100, python_env = "SDmethod_env")
```
