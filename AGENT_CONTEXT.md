# Agent Context — Hydropower Infographic Project

*Read this file when resuming work on this project to recover context.*

---

## Project goal
Final data visualization infographic for EDS 240, focused on **hydropower reservoir GHG emissions** and carbon intensity. The story: reservoirs are a non-trivial source of CO₂ and CH₄; methane pathways dominate; many dams fail the "low-carbon" target.

---

## Key papers & data sources

1. **Soued et al. (2022)** — *Nature Geoscience*  
   "Reservoir CO2 and CH4 emissions and their climate impact over the period 1900–2060"  
   - Data: `data/moesm.xlsx` (year-by-year emissions, RF, pathways, RCP scenarios)  
   - Four pathways: CO₂ diffusion, CH₄ diffusion, CH₄ ebullition, CH₄ degassing  
   - Main plot: emissions peaked ~1987; RF keeps rising (decoupling)

2. **Li & He (2022)** — *Renewable and Sustainable Energy Reviews 162, 112433*  
   "Carbon intensity of global existing and future hydropower reservoirs"  
   - Data: supplementary Tables S2–S3 only (no per-reservoir dataset)  
   - Main results: median CI ~63 kg CO₂e/MWh; 44% existing / 66% future dams fail 80 kg target; shallow + eutrophic = high CI

3. **GLEAM LCA** — `data/EF_Table_FINAL.xlsx` (lifecycle emissions by tech)

4. **GRanD + FHReD** — in `data/` for spatial dam data (used for Li & He–style viz if needed)

---

## Key files in this repo

| File | Purpose |
|------|---------|
| `final_graphics/` | **Final poster graphics** — one QMD per viz; `combine_preview.R` assembles preview |
| `soued_reservoir_viz.qmd` | 20 viz from Soued/moesm: decoupling, pathway shift, etc. |
| `li_he_hydro_ci.qmd` | 8 viz from Li & He: CI comparison, depth/trophic, share failing |
| `hydro_NZE_annex.R` | IEA NZE viz: capacity doubling, renewables mix |
| `final_countdown.qmd` | Hydro sun, hex bin (marginal-generation data) |

---

## Data loading (Soued viz)

```r
raw_ts <- readxl::read_xlsx(here::here("data/moesm.xlsx"), sheet = 1)
```

Columns: `Year`, `CO2_diff`, `CH4_diff`, `CH4_bub`, `CH4_deg`, `RF_tot_rcp4/6/8`, `RF_co2dif_rcp6`, etc., `Cumulative_reservoir_area`.

---

## Four emission pathways (Soued)

- **CO₂ diffusion** — dissolved CO₂ from water surface  
- **CH₄ diffusion** — dissolved CH₄ from water surface  
- **CH₄ ebullition** — bubbles from sediments  
- **CH₄ degassing** — CH₄ released when water passes turbines/spillways  

Shift over time: CO₂ dominated early; CH₄ ebullition + degassing dominate by 2060.

---

## Packages used

`tidyverse`, `scales`, `patchwork`, `readxl`, `here`. No `ggstream` (was removed).

---

## Final poster layout (top → bottom)

1. Sun — hydro generation pattern (hour × month)  
2. Capacity doubling — IEA 2019→2050  
3. Renewables mix — stacked area  
4. Dam schematic — visual anchor  
5. Pathway shift — CO2 → CH4 (Soued)  
6. Decoupling — emissions vs RF  
7. Good vs bad CI — depth & trophic (Li & He)  
8. Share failing 80 kg — existing vs future  
9. Who benefits / who pays — tradeoffs  

Run: `quarto render final_graphics/*.qmd` then `Rscript final_graphics/combine_preview.R`
