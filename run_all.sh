#!/usr/bin/env bash
# Reproduces every number, table and figure in the manuscript from a clean
# checkout. Expected wall time: under 30 minutes on one CPU core.
set -euo pipefail
cd "$(dirname "$0")"

export PYTHONPATH="$PWD/src:${PYTHONPATH:-}"
export VESICLE_DATA_DIR="$PWD/data"
export VESICLE_RESULTS_DIR="$PWD/results"
export VESICLE_FIGS_DIR="$PWD/figs"
export VESICLE_MS_DIR="$PWD/manuscript"
mkdir -p results figs manuscript

echo "== 0. verification tests (these check the paper's structural claims) =="
python -m pytest tests/ -q

if [ ! -f data/go-basic.obo ]; then
  echo "== 1. downloading public data =="
  bash data/download_data.sh
else
  echo "== 1. data already present, skipping download =="
fi

echo "== 2. model, identifiability, compensation and design results =="
python src/make_results.py

echo "== 3. human genomic and transcriptomic validation =="
python src/make_genomics.py

echo "== 4. figures =="
python src/make_figures.py

echo "== 5. tables and figure captions =="
python src/build_tables.py

echo "== 6. manuscript with numbered references =="
python src/build_manuscript.py

echo
echo "Done. Outputs:"
echo "  results/results.json   model, identifiability, compensation, design"
echo "  results/genomics.json  human-data association results"
echo "  results/*.csv          every table in the manuscript"
echo "  figs/*.pdf  figs/*.png vector and 600 dpi figures"
echo "  manuscript/manuscript_final.md"
