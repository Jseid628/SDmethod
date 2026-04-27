#' Run simulation in parallel
#'
#' This function creates a figure comparing the bias of the estimators in the users current working directory.
#' It also returns a summary of the lengths of the Monte Carlo iterations.
#'
#' @param rho Mixing coefficient
#' @param n_sim Number of simulations
#' @param output_dir The user's working directory
#' @param python_env Path to a python virtual environment with the necessary dependencies, see README.
#' @param num_workers Number of cores to use to run the simulation
#' @param n_units
#'
#' @examples
#' \dontrun{
#' run_sim_parallel(rho = 1,
#'                  n_sim = 3,
#'                  python_env="path/to/your/env"
#'                  )
#' }
#' @export
run_sim_parallel <- function(rho, n_sim, output_dir = getwd(),python_env=NULL, num_workers = NULL,n_units=NULL, D=NULL) {
  message("Running simulation...(Ignore silly CVXPY errors)")
  if (is.null(num_workers)) {
    num_workers <- parallel::detectCores() - 1
  }
  if (is.null(n_units)) {
    n <- 50
  } else {
    n <- n_units # number of units
  }
  if (is.null(D)) {
    embedding_dim = 10
  } else {
    embedding_dim = D
  }

  suppressWarnings(suppressMessages({
    settings_list <- list(
      list(t_total=10, k_total=4, file_suffix="T_0=10,K=4"),
      list(t_total=10, k_total=10, file_suffix="T_0=10,K=10"),
      list(t_total=40, k_total=4, file_suffix="T_0=40,K=4"),
      list(t_total=40, k_total=10, file_suffix="T_0=40,K=10")
    )

    all_bias_sim_long <- data.frame()
    iteration_lengths <- data.frame(
      setting = character(),
      sim = integer(),
      iter_length = numeric()
    )

    # Claude was very helpful with writing the parallelization piece here:
    # mclapply did not work with Reticulate and Claude suggested the future package.
    future::plan(future::multisession, workers = num_workers)
    results <- furrr::future_map(settings_list, function(setting) {
      if (!is.null(python_env)) {
        reticulate::use_virtualenv(python_env, required = TRUE)
      }

      # N x 1 vector
      mu <- list(c = seq(5, 1, length.out = n))
      mu$c[c(1, 2)] <- mu$c[c(2, 1)]; # hand-code factor loadings for n = 50 (common part)
      trt <- numeric(n); trt[1] <- 1; # select the unit with the second largest loadings to be the treated unit
      t_total <- setting$t_total
      k_total <- setting$k_total

      model <- generateModel(t_total, k_total, trt, mu, rho, n)

      columns_bias <- c("sep","cat","avg","Q")
      bias_sim <- data.frame(matrix(nrow = 0, ncol = length(columns_bias)))
      colnames(bias_sim) <- columns_bias

      all_results <- lapply(1:n_sim, function(s) {
        iter_start = proc.time()
        result <-fit_models(model, n, trt, k_total, t_total, variance = 1, num_timepoints = 40,embedding_dim)
        result$iter_time <- (proc.time() - iter_start)["elapsed"]
        return(result)
      })

      bias_sim <- data.frame(matrix(nrow = 0, ncol = length(columns_bias)))
      colnames(bias_sim) <- columns_bias
      iter_lengths <- data.frame(setting = character(), sim = integer(), iter_length = numeric())

      # reassemble
      for (s in 1:n_sim) {
        result <- all_results[[s]]
        iter_lengths <- rbind(iter_lengths, data.frame(
          setting = setting$file_suffix,
          sim = s,
          iter_length = result$iter_time
        ))
        bias_sim[s,] <- result$oracle_bias
      }

      # bias info
      bias_sim_long <- bias_sim |>
        tidyr::pivot_longer(columns_bias, names_to = "method", values_to = "bias") |>
        dplyr::mutate(setting = setting$file_suffix)

      return(list(bias_sim_long = bias_sim_long, iter_lengths = iter_lengths))
      ## end function ##
    }, .options = furrr::furrr_options(
      globals = c("rho","n_sim","python_env"),
      seed = TRUE,
      packages = "SDmethod"
      )
    )

    future::plan(future::sequential)

    # reassemble across settings
    all_bias_sim_long <- data.frame()
    iteration_lengths <- data.frame(setting = character(), sim = integer(), iter_length = numeric())

    for (i in 1:length(settings_list)) {
      all_bias_sim_long <- rbind(all_bias_sim_long, results[[i]]$bias_sim_long)
      iteration_lengths <- rbind(iteration_lengths, results[[i]]$iter_lengths)
    }

    # summary statistics for iteration lengths by setting.
    iteration_summary <- iteration_lengths |>
      dplyr::group_by(setting) |>
      dplyr::summarize(
        mean_time = mean(iter_length),
        median_time = median(iter_length),
        sd_time = sd(iter_length),
        min_time = min(iter_length),
        max_time = max(iter_length)
      )

    create_figure(n_sim,all_bias_sim_long,output_dir=output_dir)

  }))
  message("Done!")
  message("Summary of Monte Carlo Simulation Iteration Lengths: ")
  return(iteration_summary)
}
