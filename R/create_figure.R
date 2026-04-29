#' Creates a figure
#'
#' This function creates a figure that compares the bias of the four estimators under the different settings.
#'
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_boxplot
#' @importFrom ggplot2 stat_summary
#' @importFrom ggplot2 facet_wrap
#' @importFrom ggplot2 geom_hline
#' @importFrom ggplot2 coord_cartesian
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 theme_minimal
#' @importFrom ggplot2 theme
#' @importFrom ggplot2 element_text
#' @importFrom ggplot2 unit
#' @importFrom ggplot2 scale_fill_manual
#'
#' @param n_sim Number of simulations
#' @param all_bias_sim_long Data frame containing information on bias from simulation
#' @param output_dir The user's working directory
#'
#' @export
create_figure <- function(n_sim,all_bias_sim_long, output_dir = getwd()) {
  dir.create(output_dir, showWarnings = FALSE)

  cbp1 <- c("#999999", "#E69F00", "#56B4E9", "#009E73", "#F0E442", "#0072B2", "#D55E00", "#CC79A7")
  # make the figure self documenting
  date_str <- format(Sys.time(), "%Y-%m-%d_%H-%M")
  bias_fig_name <- paste0("bias_fig_nsim", n_sim, "_", date_str, ".pdf")

  all_bias_sim_long$setting <- factor(all_bias_sim_long$setting, levels = c("T_0=10,K=4", "T_0=10,K=10", "T_0=40,K=4", "T_0=40,K=10"))

  p <- all_bias_sim_long |>
    ggplot(aes(x=method, y=bias, fill=method)) +
    geom_boxplot(notch=FALSE,outlier.shape=NA) +
    stat_summary(fun=mean, geom="point", shape=20, size=2, color="black", fill="black") +
    facet_wrap(~setting, scales = "fixed", nrow = 2) + # Set scales as fixed
    geom_hline(yintercept = 0, color = "black") + # Add a horizontal line at 0 to all facets
    coord_cartesian(ylim = c(-0.25, 2)) +
    labs(y = "Bias", x = "SC Method") +
    theme_minimal() +
    theme(axis.text.x = element_text(angle = 45, hjust = 1, size=12),
          axis.text.y = element_text(size=12),
          axis.title.x = element_text(size=14, face="bold"),
          axis.title.y = element_text(size=14, face="bold"),
          plot.title = element_text(size=16, face="bold", hjust=0.5),
          plot.margin = unit(c(0,0,0,0), "lines"),
          aspect.ratio = 3/4) +
    scale_fill_manual(values=cbp1)
  pdf(file.path(output_dir, bias_fig_name))
  print(p)
  dev.off()
  return(p)
}
