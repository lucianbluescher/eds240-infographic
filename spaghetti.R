hydropower_generation <- read.csv("data/hydropower-generation/hydropower-generation.csv")

per_capita_energy_stacked <- read.csv("data/per-capita-energy-stacked/per-capita-energy-stacked.csv")

per_capita_greenhouse_gas_emissions <- read.csv("data/per-capita-greenhouse-gas-emissions/per-capita-greenhouse-gas-emissions.csv")

per_capita_methane_emissions <- read.csv("data/per-capita-methane-emissions/per-capita-methane-emissions.csv")

share_electricity_hydro <- read.csv("data/share-electricity-hydro/share-electricity-hydro.csv")

summary(hydropower_generation)
summary(per_capita_energy_stacked)
summary(per_capita_greenhouse_gas_emissions)
summary(per_capita_methane_emissions)
summary(share_electricity_hydro)



# Dam emissions vs Fossil fuel emissions over time 
# per kwh of energy units
# 
# Dam should start high and go low
# FF should stay relatively even ??