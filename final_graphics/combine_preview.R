# =============================================================================
# Combine all final graphics into a single preview
# 
# Usage:
#   1. Render QMDs first: quarto render final_graphics/*.qmd
#   2. Run this script: source("final_graphics/combine_preview.R")
#
# Output: final_graphics/poster_preview.png
# =============================================================================

library(png)
library(grid)
library(gridExtra)

# Paths - run from project root
root <- if (basename(getwd()) == "final_graphics") ".." else "."
fig_dir <- file.path(root, "final_graphics")

# Figure names (order matches poster layout top -> bottom)
fig_names <- c(
  "01_sun",
  "02_capacity_doubling",
  "03_renewables_mix",
  "05_pathway_shift",
  "06_decoupling",
  "07_good_vs_bad_ci",
  "08_share_failing_80kg",
  "10_dam_building_century",
  "11_peak_to_net_zero",
  "12_river_timeline",
  "13_combined_timeline"
)

# Quarto puts figures in *_files/figure-html/ or figure-latex/
find_fig <- function(name) {
  candidates <- c(
    file.path(fig_dir, paste0(name, "_files"), "figure-html", paste0(name, "-1.png")),
    file.path(fig_dir, paste0(name, "_files"), "figure-latex", paste0(name, "-1.png")),
    file.path(fig_dir, paste0(name, ".png"))
  )
  for (p in candidates) {
    if (file.exists(p)) return(p)
  }
  NULL
}

paths <- sapply(fig_names, find_fig)
valid <- !sapply(paths, is.null)

if (!any(valid)) {
  message("No figures found. Render QMDs first:")
  message('  for f in final_graphics/*.qmd; do quarto render "$f"; done')
  message("  Or: quarto render final_graphics/01_sun.qmd (etc.)")
  stop("No figure files found.")
}

# Load images
imgs <- lapply(paths[valid], function(p) rasterGrob(readPNG(p, native = TRUE)))

# Heights for layout (relative)
heights <- rep(1, sum(valid))
if (length(heights) >= 1) heights[1] <- 1.1   # Sun

# Save preview
out_file <- file.path(fig_dir, "poster_preview.png")
png(out_file, width = 900, height = 2700, res = 150, bg = "white")

grid.arrange(
  grobs = imgs,
  ncol = 1,
  heights = heights,
  top = "Hydropower's Role in Global Net Zero — Preview"
)

dev.off()

message("Preview saved to: ", normalizePath(out_file, mustWork = FALSE))
message("Layout: tall & skinny (top -> bottom). Edit individual QMDs, re-render, run again.")
