#!/bin/bash
# Render all QMD files to HTML (and figures)
# Run from project root: bash final_graphics/render_all.sh

cd "$(dirname "$0")/.." || exit 1

for qmd in final_graphics/*.qmd; do
  echo "Rendering $qmd..."
  quarto render "$qmd" 2>/dev/null || echo "  (quarto render failed - try manually)"
done

echo ""
echo "Done. Figures in final_graphics/*_files/figure-html/"
echo "Run: Rscript final_graphics/combine_preview.R"
echo ""
