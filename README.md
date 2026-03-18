# Hydropower’s next chapter: siting, scale, and carbon

This repository houses my **EDS 240 final project**: a reproducible, story-style blog post (`index.qmd`) and supporting scripts/data used to generate the final infographic about where hydropower expansion is concentrated and why reservoir conditions matter for carbon-intensity risk.

If you want a single entry point, render the blog post and it will re-create the figures and export the infographic-ready PDFs to `images/`.

## What’s in this repo

- **`index.qmd`**: Standalone Quarto blog post that renders the final panels (map, treemap, hydropower “sun”, capacity vs carbon threshold) and exports each as a PDF.
- **`final_graphics/`**: Earlier “source” notebooks used to prototype/iterate on individual panels.
- **`data/`**: Input datasets used by the analysis (see “Data access”).
- **`images/`**: Exported figure panels (PDF) used for final layout.

## Render the blog post

From the repo root:

```bash
quarto render index.qmd
```

This produces `index.html` and writes/overwrites panel PDFs in `images/` via `ggsave()` calls inside the figure chunks.

## Data access (what you need to render)

All required inputs are expected **in-repo** under `data/` (no API keys needed). To render `index.qmd`, you need:

- **IEA NZE scenario (installed capacity)**  
  - **File**: `data/NZE2021_AnnexA.csv`  
  - **Used for**: hydropower installed capacity in **2019 vs 2050** (GW → MW) for the “capacity vs threshold” panel.

- **FHReD future dams (points + capacity)**  
  - **File**: `data/FHReD_2015_future_dams_Zarfl_et_al_beta_version/FHReD_2015_future_dams_Zarfl_et_al_beta_version.xlsx` (sheet 2)  
  - **Used for**: dam locations, planned capacity (MW), and “Major Basin” labeling; also ranks the top-10 basins for consistent coloring across panels.

- **Basin polygons for spatial join**  
  - **File**: `data/basins_lev02_geom.rds`  
  - **Used for**: assigning FHReD dam points to level-2 basin polygons and mapping basin-level summed MW.

- **Li & He threshold shares (compiled)**  
  - **File**: `data/share_failing_80kg.csv`  
  - **Used for**: splitting NZE capacity totals into “above vs below 80 kg CO2e/MWh” shares (illustrative application of reported reservoir shares).

- **Hydropower timing dataset (regional example)**  
  - **File**: `data/marginal-generation-offsets-data.dta`  
  - **Used for**: the hydropower “sun” panel using a timestamp field (`dt`) and an hourly hydropower signal (`h`), summarized across months and hours and normalized.

## Repository structure (quick map)

```text
.
├── index.qmd                      # Standalone blog post (main deliverable)
├── final_graphics/                # Prototype/iteration notebooks for panels
├── data/                          # Inputs (CSV, XLSX, RDS, DTA)
├── images/                        # Exported figure panels (PDF)
└── hydro_NZE_annex.R              # Supporting analysis script(s)
```

## Authors / contributors

- **Lucian Blue Scher** — author  
  - Website: `https://lucianbluescher.github.io`

## References & acknowledgements

Huge thank you to Annie and Sam for teaching this course wonderfully!

### Data + scientific references

- **IEA**. *Net Zero by 2050: A Roadmap for the Global Energy Sector* (Annex A data used via `NZE2021_AnnexA.csv`).  
  - Report page: `https://www.iea.org/reports/net-zero-by-2050`

- **GlobalDamWatch / FHReD** (Future Hydropower Reservoirs and Dams).  
  - Project page: `https://www.globaldamwatch.org/fhred/`  
  - Associated publication: Zarfl et al. (2015), *PNAS*. `https://www.pnas.org/doi/10.1073/pnas.1509007112`

- **HydroSHEDS / HydroBASINS (BasinATLAS)** basin boundaries (level-2 basins used via `basins_lev02_geom.rds`).  
  - Product page: `https://www.hydrosheds.org/products/hydrobasins`

- **Li & He (2022)** reservoir carbon-intensity patterns and biome-level medians (used as contextual overlays and to compile threshold shares).  
  - DOI: `https://doi.org/10.1016/j.rser.2022.112251`

### Tools

- **Quarto** for rendering: `https://quarto.org/`  
- **R** + packages including `tidyverse`, `sf`, `ggplot2`, `treemapify`, `ggrepel`, `patchwork`, `haven`.
