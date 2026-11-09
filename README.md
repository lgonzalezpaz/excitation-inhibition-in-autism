# The excitation–inhibition ratio cannot identify its own cause: A computational study of release statistics distinguishes primary from compensatory presynaptic change in autism

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.1450812204.svg)](https://doi.org/10.5281/zenodo.1450812204)
[![Python 3.13](https://img.shields.io/badge/Python-3.13-blue.svg)](https://www.python.org/)

Code, analytical models, validation pipelines and reproducibility materials for the manuscript:

> **The excitation–inhibition ratio cannot identify its own cause: A computational study of release statistics distinguishes primary from compensatory presynaptic change in autism**  
> *Ysaías J. Alvarado, Máximo Quintero, Arlene Cardozo-Urdaneta, Carla Lossada, Yovani Marrero-Ponce, Félix Martinez-Rios, Yunierkis Pérez-Castillo, Ariana Delgado, and Lenin González-Paz.*

---

## Overview

Whether the altered excitation–inhibition balance in idiopathic autism is a primary biophysical defect or a homeostatic response has been debated for two decades without resolution. This repository provides the exact mathematical framework and computational pipeline demonstrating that this impasse is not an empirical shortfall, but a structural identifiability limitation:

1. **Structural Non-Identifiability of the Mean**: The mean synaptic drive is a product of presynaptic parameters ($\mu = N P q$). Its sensitivity Jacobian has rank one, leaving a three-dimensional parameter null space. No measurement of the excitation–inhibition ratio alone can distinguish a loss of release sites from a change in fusion probability or quantal amplitude.
2. **Compensation-Invariant Residual Geometry**: When a homeostatic controller restores the mean drive, it cannot simultaneously restore the coefficient of variation ($\mathrm{CV}^2$) and the paired-pulse ratio ($\mathrm{PPR}$). Lesions leave a non-zero residual whose trajectory in the $(\Delta \log \mathrm{CV}_1^2, \Delta \log \mathrm{PPR})$ plane identifies the lesioned parameter. Release-site ($N$) and resupply ($k_{\mathrm{rep}}$) lesions lie on exactly orthogonal axes ($0^\circ$ and $-90^\circ$). The single exception—a fusion-probability lesion compensated presynaptically—is identically erased and formally undecidable.
3. **Resupply-Limited Compensation Ceiling**: Sustained drive during high-frequency stimulation is strictly bounded by vesicle resupply: $\lim_{p \to 1} D(p) = N q (1 - e^{-k_{\mathrm{rep}}/r})$, which contains no fusion probability term. At 20 Hz, presynaptic gain can offset only 9.6% loss of excitatory sites and 2.4% of inhibitory sites.
4. **Human Genomic and Transcriptomic Signature**: Presynaptic genes on the actuator axis (calcium entry, calcium sensing, secretory modulation) are coherently downregulated in autistic cortex (3.0-fold enrichment, $P = 1 \times 10^{-4}$), whereas capacity-axis genes are not.

---

## Repository Structure

```
excitation-inhibition-in-autism/
├── .zenodo.json              # Zenodo deposit metadata (Invenio compliant)
├── CITATION.cff              # Citation metadata (CFF 1.2.0)
├── LICENSE                   # MIT Open Source License
├── README.md                 # Documentation and execution guide
├── environment.yml           # Conda environment definition
├── requirements.txt          # Python dependencies
├── run_all.sh                # End-to-end master reproduction script
├── data/
│   ├── CHECKSUMS.sha256      # Checksums for external reference datasets
│   └── download_data.sh      # Public genomic/transcriptomic data downloader
├── figs/                     # Vector (PDF) and 600-dpi publication figures (Figs 1–6)
├── manuscript/
│   ├── README.md
│   ├── manuscript.docx       # Publication-ready Word manuscript (OMML math)
│   ├── manuscript_final.md   # Final formatted markdown with LaTeX equations
│   ├── references_numbered.md # Vancouver-style numbered bibliography (1–52)
│   └── refs_verified.json    # PubMed/Crossref verified citation database
├── results/                  # Generated CSV and JSON data tables
├── src/                      # Core analysis, modeling, and plotting routines
│   ├── analysis_core.py      # Jacobian elasticities and residual geometry
│   ├── build_docx.py         # Word document styling and math formatting
│   ├── build_manuscript.py   # Citation resolution and Markdown build
│   ├── build_tables.py       # Generation of manuscript tables from results
│   ├── ceiling.py            # Presynaptic homeostatic capacity ceiling
│   ├── figstyle.py           # Publication styling parameters
│   ├── genomics.py           # Human genomic and transcriptomic pipeline
│   ├── identifiability.py    # Structural identifiability and null space
│   ├── identifiability2.py   # Fisher information and experimental design
│   ├── make_figures.py       # Generates Figures 1 to 6
│   ├── make_genomics.py      # Executes genomic association pipeline
│   ├── make_results.py       # Computes all model metrics
│   ├── mpfa.py               # Multiple-probability fluctuation analysis
│   ├── params_literature.py  # Synaptic parameters with literature provenance
│   └── release_model.py      # Exact moment recursions and Monte Carlo
└── tests/
    └── test_model.py         # Comprehensive unit tests (23 tests)
```

---

## Quick Start & Reproduction

### 1. Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/lgonzalezpaz/excitation-inhibition-in-autism.git
cd excitation-inhibition-in-autism

# Option A: Conda
conda env create -f environment.yml
conda activate vesicle-ei

# Option B: Pip / venv
python -m venv .venv
# On Linux/macOS:
source .venv/bin/activate
# On Windows (PowerShell):
.venv\Scripts\Activate.ps1

pip install -r requirements.txt pytest
```

### 2. Run Tests

To verify mathematical identities, structural zeros, and moment recursions:

```bash
python -m pytest tests/ -v
```

### 3. End-to-End Pipeline

To reproduce all figures, tables, and numerical outputs from scratch:

```bash
# On Linux / macOS / Git Bash:
bash run_all.sh

# Or directly in Python:
python src/make_results.py
python src/make_genomics.py
python src/make_figures.py
python src/build_tables.py
```

Total execution time is under 15 minutes on a standard desktop CPU.

---

## Instructions for Zenodo Archival & DOI Generation

To activate and update the archive on Zenodo:

1. Log in to [Zenodo](https://zenodo.org/) (or Zenodo Sandbox) and navigate to **GitHub** in your profile settings.
2. Ensure the toggle switch for `lgonzalezpaz/excitation-inhibition-in-autism` is turned **ON**.
3. On GitHub (`https://github.com/lgonzalezpaz/excitation-inhibition-in-autism`), go to **Releases** > **Draft a new release**.
4. Enter tag version: `v1.0.0` (target: `main`).
5. Title: `v1.0.0: Initial release for publication`.
6. Click **Publish release**.
7. Zenodo will automatically receive the webhook, ingest the preconfigured `.zenodo.json` metadata and `CITATION.cff`, assign a permanent DOI, and archive the complete codebase snapshot without errors.

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
