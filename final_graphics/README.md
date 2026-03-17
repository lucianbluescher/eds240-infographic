# Final Infographic Graphics

Individual graphics for the hydropower storymap poster. Each QMD can be edited independently and combined using `combine_preview.R`.

## Layout (top to bottom)

1. **01_sun.qmd** — Hydro generation "sun" (hour × month circular heatmap)
2. **02_capacity_doubling.qmd** — IEA: hydro must double 2019→2050
3. **03_renewables_mix.qmd** — Stacked area: hydro share declines as solar/wind grow
4. **05_pathway_shift.qmd** — CO2 → CH4 dominance (Soued)
5. **06_decoupling.qmd** — Emissions peak vs RF keeps rising
6. **07_good_vs_bad_ci.qmd** — Depth/trophic CI (Li & He)
7. **08_share_failing_80kg.qmd** — % meeting 80 kg target
8. **10_dam_building_century.qmd** — Cumulative reservoir count 1900–2060, big dams
9. **11_peak_to_net_zero.qmd** — Emissions timeline: peak 1987 → net zero 2050
10. **12_river_timeline.qmd** — River styles (A–D) + combined 1950–2050 with branches  
11. **13_combined_timeline.qmd** — Decoupling + peak to net zero + river, stacked, 1950–2050

## Usage

1. **Render all QMDs**: `quarto render final_graphics/01_sun.qmd` (repeat for each) or `bash final_graphics/render_all.sh`
2. **Combine preview**: `Rscript final_graphics/combine_preview.R` → creates `poster_preview.png`
3. **Edit individually**: Each QMD is standalone; edit, re-render, re-combine

## Data sources

- `../data/marginal-generation-offsets-data.dta` — Sun viz (regional)
- `../data/NZE2021_AnnexA.csv` — Capacity, renewables mix
- `../data/moesm.xlsx` — Pathway shift, decoupling, dam building, peak to net zero
- `../data/hydropower-generation/`, `../data/share-electricity-hydro/` — OWID (river timeline)
- Li & He (2022) — CI, share failing (hardcoded)
