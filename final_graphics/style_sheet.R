# Okabe-Ito Extended: High contrast, maximum accessibility
okabe_ito_11 <- c(
  "#F0E442", # 1. Yangtze
  "#004E89", # 2. Amazon
  "#E69F00", # 3. Indus
  "#CC79A7", # 4. Ganges - Brahmaputra
  "#0072B2", # 5. Congo
  "#117733", # 6. Mekong
  "#D55E00", # 7. Salween
  "#56B4E9", # 8. La Plata
  "#009E73", # 9. Irrawady
  "#442288", # 10. Nile
  "#999999"  # 11. Other basins (grey)
)

# Shared style helpers for final graphics
# Keep palettes here so colors remain consistent across figures.

make_top10_basin_palette <- function(top_basins,
                                    other_label = "Other basins") {
  top_basins <- as.character(top_basins)
  if (length(top_basins) != 10) {
    stop("make_top10_basin_palette() expects exactly 10 basin names.")
  }

  cols <- okabe_ito_11
  names(cols) <- c(paste0(1:10, ". ", top_basins), other_label)
  cols
}