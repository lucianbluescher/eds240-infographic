# ============================================================================
# 5 Unique Visualizations: Hydropower's Role in Net Zero by 2050
# Supporting "Hydropower's Low-Hanging Fruits" Thesis
# ============================================================================

library(tidyverse)
library(ggplot2)
library(scales)
library(patchwork)
library(ggrepel)
library(viridis)
library(RColorBrewer)

# ============================================================================
# DATA PREPARATION
# ============================================================================
# Load the IEA Net Zero by 2050 data
nze_data <- read.csv("data/NZE2021_AnnexA.csv")

# Expected columns: Publication, Scenario, Category, Product, Flow, Unit, Year, Value

# Filter and prepare hydropower data
hydro_data <- nze_data %>%
    filter(
        Product == "Hydro" | 
            (Product == "Total" & Flow == "Electricity generation") |
            (Product == "Renewables" & Flow == "Electricity generation") |
            (Product == "Solar PV" & Flow == "Electricity generation") |
            (Product == "Wind" & Flow == "Electricity generation") |
            (Product == "Nuclear" & Flow == "Electricity generation") |
            (Product == "Unabated coal" & Flow == "Electricity generation") |
            (Product == "Unabated natural gas" & Flow == "Electricity generation") |
            (Product == "Oil products" & Flow == "Electricity generation") |
            (Product == "Total" & Flow == "Installed total power capacity") |
            (Product == "Hydro" & Flow == "Installed total power capacity")
    ) %>%
    filter(Year %in% c(2019, 2020, 2030, 2040, 2050)) %>%
    mutate(
        Product = case_when(
            Product == "Hydro" ~ "Hydropower",
            TRUE ~ Product
        )
    )

# Create generation dataset
generation <- hydro_data %>%
    filter(Flow == "Electricity generation", Unit == "TWh") %>%
    select(Product, Year, Value) %>%
    pivot_wider(names_from = Product, values_from = Value) %>%
    mutate(
        Other_Renewables = Renewables - Hydropower - `Solar PV` - Wind,
        Hydropower_Share_Renewables = (Hydropower / Renewables) * 100,
        Hydropower_Share_Total = (Hydropower / Total) * 100,
        # Calculate fossil fuel totals (handle missing columns with coalesce)
        Coal_Gen = coalesce(`Unabated coal`, 0),
        Gas_Gen = coalesce(`Unabated natural gas`, 0),
        Oil_Gen = coalesce(`Oil products`, 0),
        Fossil_Fuels = Coal_Gen + Gas_Gen + Oil_Gen
    )

# Create capacity dataset
capacity <- hydro_data %>%
    filter(Flow == "Installed total power capacity", Unit == "GW") %>%
    select(Product, Year, Value) %>%
    pivot_wider(names_from = Product, values_from = Value) %>%
    mutate(
        Capacity_Increase_2019_2050 = Hydropower - lag(Hydropower, n = 4, default = first(Hydropower)),
        Capacity_Doubling_Target = first(Hydropower) * 2
    )

# Calculate growth metrics
growth_metrics <- generation %>%
    filter(Year %in% c(2019, 2050)) %>%
    select(Year, Hydropower, `Solar PV`, Wind, Total) %>%
    pivot_longer(cols = -Year, names_to = "Source", values_to = "Generation") %>%
    pivot_wider(names_from = Year, values_from = Generation) %>%
    mutate(
        Growth_2019_2050 = `2050` - `2019`,
        Growth_Percent = ((`2050` - `2019`) / `2019`) * 100,
        CAGR = ((`2050` / `2019`) ^ (1/31)) - 1
    )

# ============================================================================
# VISUALIZATION 1: Hydropower Must Double - Side-by-Side Comparison
# Shows the doubling requirement with clear visual emphasis
# ============================================================================

viz1_data <- capacity %>%
    filter(Year %in% c(2019, 2050)) %>%
    select(Year, Hydropower) %>%
    mutate(
        Year_Label = case_when(
            Year == 2019 ~ "2019\n(Current)",
            Year == 2050 ~ "2050\n(Needed)"
        ),
        Doubling_Target = first(Hydropower) * 2,
        Is_Doubled = Hydropower >= Doubling_Target
    )

# Calculate the doubling ratio
doubling_ratio <- last(viz1_data$Hydropower) / first(viz1_data$Hydropower)

viz1 <- ggplot(viz1_data, aes(x = Year_Label, y = Hydropower)) +
    # Reference line showing exact 2x target
    geom_hline(
        yintercept = first(viz1_data$Doubling_Target),
        linetype = "dashed",
        color = "#A23B72",
        size = 1,
        alpha = 0.6
    ) +
    # Bars
    geom_col(aes(fill = Year_Label), width = 0.5, alpha = 0.85) +
    # Value labels on bars
    geom_text(
        aes(label = paste0(round(Hydropower), " GW")),
        vjust = -0.3,
        size = 6,
        fontface = "bold"
    ) +
    # Doubling indicator arrow and text
    geom_segment(
        aes(x = 1, xend = 2, y = first(Hydropower), yend = first(Hydropower)),
        color = "#A23B72",
        size = 1.5,
        linetype = "dashed",
        alpha = 0.5
    ) +
    geom_segment(
        aes(x = 2, xend = 2, y = first(Hydropower), yend = last(Hydropower)),
        color = "#2E86AB",
        size = 2,
        arrow = arrow(length = unit(0.4, "cm"), type = "closed")
    ) +
    # "2x" annotation
    annotate(
        "text",
        x = 1.5,
        y = (first(viz1_data$Hydropower) + last(viz1_data$Hydropower)) / 2,
        label = paste0("×", round(doubling_ratio, 2)),
        size = 12,
        fontface = "bold",
        color = "#A23B72",
        angle = 90
    ) +
    # Additional growth annotation
    annotate(
        "text",
        x = 2.3,
        y = (first(viz1_data$Hydropower) + last(viz1_data$Hydropower)) / 2,
        label = paste0("+", round(last(viz1_data$Hydropower) - first(viz1_data$Hydropower)), " GW\nneeded"),
        size = 4.5,
        fontface = "bold",
        color = "#2E86AB",
        hjust = 0
    ) +
    # Reference line label
    annotate(
        "text",
        x = 0.7,
        y = first(viz1_data$Doubling_Target),
        label = "2× Target",
        size = 3.5,
        color = "#A23B72",
        fontface = "italic",
        hjust = 1,
        vjust = -0.5
    ) +
    scale_fill_manual(
        values = c("2019\n(Current)" = "#6C757D", "2050\n(Needed)" = "#2E86AB"),
        guide = "none"
    ) +
    labs(
        title = "Hydropower Capacity Must Double by 2050",
        subtitle = paste0("Net Zero scenario requires ", round(doubling_ratio, 2), "× current capacity: ", 
                          round(first(viz1_data$Hydropower)), " GW → ", round(last(viz1_data$Hydropower)), " GW"),
        x = "",
        y = "Installed Capacity (GW)",
        caption = "Source: IEA Net Zero by 2050 Scenario | Dashed line shows exact 2× target"
    ) +
    theme_minimal(base_size = 14) +
    theme(
        plot.title = element_text(size = 20, face = "bold", color = "#1a1a1a"),
        plot.subtitle = element_text(size = 13, color = "#666666", margin = margin(b = 20)),
        axis.text.x = element_text(size = 13, face = "bold"),
        axis.text.y = element_text(size = 11),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        panel.grid.major.y = element_line(color = "#E0E0E0"),
        plot.caption = element_text(size = 9, color = "#999999", hjust = 0)
    ) +
    ylim(0, max(viz1_data$Hydropower) * 1.25)

# ============================================================================
# VISUALIZATION 2: Radial Growth Comparison - Energy Transition Spiral
# Shows hydropower growth trajectory vs renewables AND fossil fuel decline
# ============================================================================

viz2_data <- generation %>%
    select(Year, Hydropower, `Solar PV`, Wind, Nuclear, Fossil_Fuels) %>%
    pivot_longer(cols = -Year, names_to = "Source", values_to = "Generation") %>%
    mutate(
        Source_Type = case_when(
            Source == "Fossil_Fuels" ~ "Fossil Fuels",
            Source %in% c("Hydropower", "Solar PV", "Wind") ~ "Renewables",
            Source == "Nuclear" ~ "Nuclear"
        )
    ) %>%
    group_by(Source) %>%
    mutate(
        Index_2019 = first(Generation),
        Indexed_Value = case_when(
            Index_2019 > 0 ~ (Generation / Index_2019) * 100,
            TRUE ~ 0
        )
    ) %>%
    ungroup()

viz2 <- ggplot(viz2_data, aes(x = Year, y = Indexed_Value, color = Source, linetype = Source_Type)) +
    geom_line(size = 2, alpha = 0.85) +
    geom_point(size = 4.5, alpha = 0.9) +
    geom_hline(yintercept = 200, linetype = "dashed", color = "#A23B72", alpha = 0.4, size = 0.8) +
    geom_hline(yintercept = 100, linetype = "dashed", color = "#666666", alpha = 0.3, size = 0.5) +
    geom_hline(yintercept = 0, linetype = "solid", color = "#C73E1D", alpha = 0.5, size = 1) +
    annotate(
        "text",
        x = 2045,
        y = 200,
        label = "2× (Doubling)",
        color = "#A23B72",
        size = 3.5,
        fontface = "bold"
    ) +
    annotate(
        "text",
        x = 2045,
        y = 100,
        label = "Baseline (2019)",
        color = "#666666",
        size = 3,
        fontface = "italic"
    ) +
    annotate(
        "text",
        x = 2045,
        y = 5,
        label = "Zero",
        color = "#C73E1D",
        size = 3.5,
        fontface = "bold"
    ) +
    coord_polar(theta = "x", start = -pi/2, direction = 1) +
    scale_color_manual(
        values = c(
            "Hydropower" = "#2E86AB",
            "Solar PV" = "#F18F01",
            "Wind" = "#C73E1D",
            "Nuclear" = "#6A4C93",
            "Fossil_Fuels" = "#8B4513"
        ),
        labels = c("Hydropower", "Solar PV", "Wind", "Nuclear", "Fossil Fuels")
    ) +
    scale_linetype_manual(
        values = c("Renewables" = "solid", "Nuclear" = "solid", "Fossil Fuels" = "dashed"),
        guide = "none"
    ) +
    scale_x_continuous(breaks = c(2019, 2030, 2040, 2050)) +
    scale_y_continuous(limits = c(0, max(viz2_data$Indexed_Value) * 1.1)) +
    labs(
        title = "Energy Transition Spiral: Renewables Rise, Fossils Fall",
        subtitle = "Indexed to 2019 (100 = baseline). Hydropower doubles while Solar/Wind surge 10-15×. Fossil fuels collapse to near-zero.",
        color = "Energy Source",
        caption = "Source: IEA Net Zero by 2050 Scenario"
    ) +
    theme_minimal(base_size = 13) +
    theme(
        plot.title = element_text(size = 17, face = "bold", hjust = 0.5),
        plot.subtitle = element_text(size = 11, hjust = 0.5, margin = margin(b = 15)),
        legend.position = "bottom",
        legend.box = "horizontal",
        panel.grid.major = element_line(color = "#E0E0E0", linetype = "dashed"),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 9),
        plot.caption = element_text(size = 9, color = "#999999")
    )

# ============================================================================
# VISUALIZATION 3: Stacked Area - Hydropower's Share of Renewables
# Shows how hydropower's relative contribution changes as renewables scale
# ============================================================================

viz3_data <- generation %>%
    select(Year, Hydropower, `Solar PV`, Wind, Other_Renewables) %>%
    pivot_longer(cols = -Year, names_to = "Source", values_to = "Generation") %>%
    mutate(
        Source = factor(Source, levels = c("Other_Renewables", "Wind", "Solar PV", "Hydropower")),
        Source_Label = case_when(
            Source == "Other_Renewables" ~ "Other Renewables",
            Source == "Solar PV" ~ "Solar PV",
            Source == "Wind" ~ "Wind",
            Source == "Hydropower" ~ "Hydropower"
        )
    )

viz3 <- ggplot(viz3_data, aes(x = Year, y = Generation, fill = Source_Label)) +
    geom_area(alpha = 0.85, color = "white", size = 0.3) +
    geom_line(
        data = generation,
        aes(x = Year, y = Hydropower),
        inherit.aes = FALSE,
        color = "#1a1a1a",
        size = 1.2,
        linetype = "dashed"
    ) +
    geom_text(
        data = generation %>% filter(Year == 2050),
        aes(x = 2050, y = Hydropower, label = paste0(round(Hydropower_Share_Renewables, 1), "% of renewables")),
        inherit.aes = FALSE,
        hjust = -0.1,
        vjust = 0.5,
        size = 4,
        fontface = "bold",
        color = "#2E86AB"
    ) +
    scale_fill_manual(
        values = c("Hydropower" = "#2E86AB", "Solar PV" = "#F18F01", "Wind" = "#C73E1D", "Other Renewables" = "#6C757D"),
        guide = guide_legend(reverse = TRUE)
    ) +
    scale_x_continuous(breaks = c(2019, 2020, 2030, 2040, 2050)) +
    scale_y_continuous(labels = comma_format()) +
    labs(
        title = "Hydropower's Evolving Role in Renewable Electricity Mix",
        subtitle = "While absolute generation doubles, hydropower's share of renewables declines as Solar/Wind scale faster",
        x = "Year",
        y = "Electricity Generation (TWh)",
        fill = "Energy Source",
        caption = "Source: IEA Net Zero by 2050 Scenario | Dashed line shows hydropower absolute generation"
    ) +
    theme_minimal(base_size = 13) +
    theme(
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 11, color = "#666666", margin = margin(b = 15)),
        legend.position = "bottom",
        panel.grid.minor = element_blank(),
        plot.caption = element_text(size = 9, color = "#999999")
    )

# ============================================================================
# VISUALIZATION 3B: Growth Multiplier Comparison
# Shows the same concept as viz3 but with growth multipliers
# ============================================================================

viz3b_data <- generation %>%
    filter(Year %in% c(2019, 2050)) %>%
    select(Year, Hydropower, `Solar PV`, Wind) %>%
    pivot_longer(cols = -Year, names_to = "Source", values_to = "Generation") %>%
    pivot_wider(names_from = Year, values_from = Generation) %>%
    mutate(
        Multiplier = `2050` / `2019`,
        Source_Label = Source,
        Growth_Label = case_when(
            Multiplier >= 10 ~ paste0(round(Multiplier, 1), "×"),
            TRUE ~ paste0(round(Multiplier, 2), "×")
        )
    )

viz3b <- ggplot(viz3b_data, aes(x = reorder(Source_Label, Multiplier), y = Multiplier, fill = Source_Label)) +
    geom_col(width = 0.7, alpha = 0.85) +
    geom_text(
        aes(label = Growth_Label),
        hjust = -0.1,
        size = 6,
        fontface = "bold"
    ) +
    geom_hline(yintercept = 2, linetype = "dashed", color = "#A23B72", size = 1, alpha = 0.6) +
    annotate(
        "text",
        x = 3.5,
        y = 2,
        label = "2× (Doubling)",
        color = "#A23B72",
        size = 4,
        fontface = "bold",
        hjust = -0.1
    ) +
    coord_flip() +
    scale_fill_manual(
        values = c("Hydropower" = "#2E86AB", "Solar PV" = "#F18F01", "Wind" = "#C73E1D"),
        guide = "none"
    ) +
    scale_y_continuous(
        name = "Growth Multiplier (2050 vs 2019)",
        breaks = c(0, 2, 5, 10, 15, 20),
        labels = c("0×", "2×", "5×", "10×", "15×", "20×"),
        expand = expansion(mult = c(0, 0.15))
    ) +
    labs(
        title = "Hydropower Doubles While Solar & Wind Explode",
        subtitle = "Growth multipliers from 2019 to 2050. Hydropower's steady 2× growth is essential baseload, while intermittent sources scale rapidly.",
        x = "",
        caption = "Source: IEA Net Zero by 2050 Scenario"
    ) +
    theme_minimal(base_size = 14) +
    theme(
        plot.title = element_text(size = 17, face = "bold"),
        plot.subtitle = element_text(size = 11, color = "#666666", margin = margin(b = 15)),
        axis.text.y = element_text(size = 12, face = "bold"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(size = 9, color = "#999999")
    )

# ============================================================================
# VISUALIZATION 4: Hydropower's Critical Role in Grid Stability
# Shows hydropower capacity needed to support intermittent renewables
# ============================================================================

# Prepare generation data for viz4
gen_viz4 <- generation %>%
    select(Year, Hydropower_Gen = Hydropower, `Solar PV`, Wind)

# Add Total if it exists
if ("Total" %in% names(generation)) {
    gen_viz4 <- gen_viz4 %>%
        left_join(generation %>% select(Year, Total_Gen = Total), by = "Year")
} else {
    gen_viz4 <- gen_viz4 %>%
        mutate(Total_Gen = NA_real_)
}

viz4_data <- capacity %>%
    left_join(gen_viz4, by = "Year") %>%
    mutate(
        Intermittent_Renewables = `Solar PV` + Wind,
        # Use Total_Gen if available, otherwise calculate from components
        Total_Generation = coalesce(Total_Gen, Intermittent_Renewables + Hydropower_Gen),
        Intermittent_Share = (Intermittent_Renewables / Total_Generation) * 100,
        Hydropower_Share = (Hydropower_Gen / Total_Generation) * 100,
        Hydro_Support_Ratio = Hydropower / (Intermittent_Renewables / 1000)
    )

viz4 <- ggplot(viz4_data, aes(x = Year)) +
    geom_area(aes(y = Intermittent_Share), fill = "#F18F01", alpha = 0.4) +
    geom_area(aes(y = Hydropower_Share), fill = "#2E86AB", alpha = 0.6) +
    geom_line(aes(y = Intermittent_Share), color = "#F18F01", size = 2) +
    geom_line(aes(y = Hydropower_Share), color = "#2E86AB", size = 2) +
    geom_text(
        data = viz4_data %>% filter(Year == 2050),
        aes(x = 2050, y = Intermittent_Share, label = paste0(round(Intermittent_Share, 1), "%\nIntermittent")),
        hjust = -0.1,
        vjust = 0.5,
        size = 4,
        color = "#F18F01",
        fontface = "bold"
    ) +
    geom_text(
        data = viz4_data %>% filter(Year == 2050),
        aes(x = 2050, y = Hydropower_Share, label = paste0(round(Hydropower_Share, 1), "%\nHydropower")),
        hjust = -0.1,
        vjust = 0.5,
        size = 4,
        color = "#2E86AB",
        fontface = "bold"
    ) +
    annotate(
        "text",
        x = 2035,
        y = (viz4_data %>% filter(Year == 2030))$Hydropower_Share[1],
        label = "Hydropower provides\nstable baseload to\nbalance intermittent\nrenewables",
        size = 3.5,
        color = "#2E86AB",
        fontface = "bold",
        hjust = 0.5,
        vjust = 0.5
    ) +
    scale_x_continuous(breaks = c(2019, 2020, 2030, 2040, 2050)) +
    scale_y_continuous(
        name = "Share of Total Generation (%)",
        labels = function(x) paste0(x, "%")
    ) +
    labs(
        title = "Hydropower: The Grid Stabilizer",
        subtitle = "As intermittent renewables (Solar/Wind) grow to 70%+ of generation, hydropower's dispatchable capacity becomes critical for grid reliability",
        x = "Year",
        caption = "Source: IEA Net Zero by 2050 Scenario"
    ) +
    theme_minimal(base_size = 13) +
    theme(
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 11, color = "#666666", margin = margin(b = 15)),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(size = 9, color = "#999999")
    )

# ============================================================================
# VISUALIZATION 5: Capacity Additions Needed - The Challenge
# Shows how capacity factor/efficiency might change over time
# ============================================================================

viz4_data <- capacity %>%
    left_join(
        generation %>% select(Year, Generation_TWh = Hydropower),
        by = "Year"
    ) %>%
    mutate(
        Capacity_Factor = (Generation_TWh * 1000) / (Hydropower * 8760) * 100, # TWh to GWh, then / (GW * hours/year)
        Capacity_Factor_Label = paste0(round(Capacity_Factor, 1), "%")
    ) %>%
    select(Year, Capacity_GW = Hydropower, Generation_TWh, Capacity_Factor, Capacity_Factor_Label)

viz4 <- ggplot(viz4_data, aes(x = Year)) +
    geom_line(aes(y = Capacity_GW * 10), color = "#2E86AB", size = 2, alpha = 0.7) +
    geom_point(aes(y = Capacity_GW * 10), color = "#2E86AB", size = 5) +
    geom_line(aes(y = Generation_TWh), color = "#F18F01", size = 2, alpha = 0.7) +
    geom_point(aes(y = Generation_TWh), color = "#F18F01", size = 5) +
    geom_text(
        aes(y = Capacity_GW * 10, label = paste0(round(Capacity_GW), " GW")),
        vjust = -1,
        hjust = 0.5,
        size = 3.5,
        color = "#2E86AB",
        fontface = "bold"
    ) +
    geom_text(
        aes(y = Generation_TWh, label = paste0(round(Generation_TWh), " TWh")),
        vjust = 1.5,
        hjust = 0.5,
        size = 3.5,
        color = "#F18F01",
        fontface = "bold"
    ) +
    geom_text(
        aes(y = (Capacity_GW * 10 + Generation_TWh) / 2, label = Capacity_Factor_Label),
        vjust = 0,
        hjust = 0.5,
        size = 3,
        color = "#666666",
        fontface = "italic"
    ) +
    scale_x_continuous(breaks = c(2019, 2020, 2030, 2040, 2050)) +
    scale_y_continuous(
        name = "Generation (TWh)",
        sec.axis = sec_axis(~ . / 10, name = "Capacity (GW)", labels = comma_format()),
        labels = comma_format()
    ) +
    labs(
        title = "Hydropower Capacity & Generation: Scaling Together",
        subtitle = "Dual-axis view showing capacity expansion (blue) and generation growth (orange). Capacity factor indicates utilization efficiency.",
        x = "Year",
        caption = "Source: IEA Net Zero by 2050 Scenario | Capacity factor = (Generation / (Capacity × 8760)) × 100"
    ) +
    theme_minimal(base_size = 13) +
    theme(
        plot.title = element_text(size = 16, face = "bold"),
        plot.subtitle = element_text(size = 11, color = "#666666", margin = margin(b = 15)),
        axis.title.y.left = element_text(color = "#F18F01", size = 11),
        axis.text.y.left = element_text(color = "#F18F01"),
        axis.title.y.right = element_text(color = "#2E86AB", size = 11),
        axis.text.y.right = element_text(color = "#2E86AB"),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(size = 9, color = "#999999")
    )

# ============================================================================
# VISUALIZATION 5: Annual Capacity Additions Needed
# Shows the challenge of meeting the 2050 target
# ============================================================================

viz5_data <- capacity %>%
    select(Year, Hydropower) %>%
    mutate(
        Annual_Addition = Hydropower - lag(Hydropower, default = first(Hydropower)),
        Period = case_when(
            Year == 2019 ~ "2019 Baseline",
            Year == 2020 ~ "2020",
            Year == 2030 ~ "2020-2030",
            Year == 2040 ~ "2030-2040",
            Year == 2050 ~ "2040-2050"
        ),
        Period_Years = case_when(
            Year == 2019 ~ 0,
            Year == 2020 ~ 1,
            Year == 2030 ~ 10,
            Year == 2040 ~ 10,
            Year == 2050 ~ 10
        ),
        Avg_Annual_Addition = Annual_Addition / Period_Years,
        Period_Label = case_when(
            Year == 2019 ~ "Baseline",
            TRUE ~ paste0(round(Avg_Annual_Addition, 1), " GW/yr")
        )
    ) %>%
    filter(Year != 2019)

viz5 <- ggplot(viz5_data, aes(x = reorder(Period, Year), y = Avg_Annual_Addition)) +
    geom_col(aes(fill = Year), width = 0.6, alpha = 0.85) +
    geom_text(
        aes(label = Period_Label),
        vjust = -0.3,
        size = 5,
        fontface = "bold"
    ) +
    geom_hline(
        yintercept = mean(filter(viz5_data, Year >= 2030)$Avg_Annual_Addition),
        linetype = "dashed",
        color = "#A23B72",
        size = 1,
        alpha = 0.6
    ) +
    annotate(
        "text",
        x = 3.5,
        y = mean(filter(viz5_data, Year >= 2030)$Avg_Annual_Addition),
        label = paste0("Average: ", round(mean(filter(viz5_data, Year >= 2030)$Avg_Annual_Addition), 1), " GW/yr"),
        color = "#A23B72",
        size = 4,
        fontface = "bold",
        hjust = -0.1
    ) +
    scale_fill_gradient(
        low = "#6C757D",
        high = "#2E86AB",
        guide = "none"
    ) +
    scale_y_continuous(
        name = "Average Annual Capacity Addition (GW/year)",
        labels = function(x) paste0(x, " GW/yr"),
        expand = expansion(mult = c(0, 0.15))
    ) +
    labs(
        title = "The Scale of Hydropower Expansion Required",
        subtitle = "To reach 2,600 GW by 2050, we need ~42 GW of new capacity per year from 2030-2050. This is equivalent to ~3-4 large dams per month globally.",
        x = "Time Period",
        caption = "Source: IEA Net Zero by 2050 Scenario | Based on capacity additions needed"
    ) +
    theme_minimal(base_size = 14) +
    theme(
        plot.title = element_text(size = 17, face = "bold"),
        plot.subtitle = element_text(size = 11, color = "#666666", margin = margin(b = 15)),
        axis.text.x = element_text(size = 11, face = "bold"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank(),
        plot.caption = element_text(size = 9, color = "#999999")
    )

# ============================================================================
# DISPLAY ALL VISUALIZATIONS
# ============================================================================

print("Visualization 1: Capacity Expansion Waterfall")
print(viz1)

print("Visualization 2: Radial Growth Comparison")
print(viz2)

print("Visualization 3: Stacked Area - Share of Renewables")
print(viz3)

print("Visualization 3B: Growth Multiplier Comparison")
print(viz3b)

print("Visualization 4: Grid Stability - Hydropower's Role")
print(viz4)

print("Visualization 5: Annual Capacity Additions Needed")
print(viz5)

# Optional: Combine into a single figure
combined <- (viz1 | viz2) / (viz3 | viz3b) / (viz4 | viz5) +
    plot_annotation(
        title = "Hydropower's Critical Path to Net Zero by 2050",
        subtitle = "Six perspectives on why hydropower expansion is essential for climate goals",
        theme = theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5),
                      plot.subtitle = element_text(size = 12, hjust = 0.5))
    )

print("Combined Figure")
print(combined)

