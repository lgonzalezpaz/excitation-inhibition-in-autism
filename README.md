# The excitation–inhibition ratio cannot identify its own cause

Code, data pipeline and reproducibility materials for the manuscript

> **The excitation–inhibition ratio cannot identify its own cause: release statistics separate primary from compensatory presynaptic change in autism**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![DOI](https://img.shields.io/badge/Zenodo-10.5281%2Fzenodo.XXXXXXX-blue)](https://doi.org/10.5281/zenodo.XXXXXXX)

---

## What this is

Whether the altered excitation–inhibition balance in idiopathic autism is a primary biophysical defect or a homeostatic response has been debated for two decades. This repository contains the analysis showing that the question cannot be answered by the measurement the field has been making, and the analysis showing what measurement would answer it.

The three central results are:

1. **The excitation–inhibition ratio is structurally non-identifiable.** The mean synaptic drive is a product of presynaptic parameters, so its sensitivity has rank one and three independent directions of parameter change leave it unaltered. This is a property of the mapping, not of the instrument.
2. **A mean-restoring controller leaves a residual that identifies the lesion.** Restoring the mean cannot restore the coefficient of variation and the paired-pulse ratio together. Release-site and resupply lesions lie on *exactly* orthogonal axes in that plane. The one exception — a fusion-probability lesion offset presynaptically — is erased identically and is formally undecidable.
3. **Presynaptic compensation has a resupply-limited ceiling.** Sustained drive is bounded by `N q (1 - exp(-k_rep/r))`, which contains no release-probability term, so capacity lesions are largely uncompensable during ongoing activity and inhibitory synapses have the least headroom.

These are validated against published measurements at three identified central synapses and tested against public human genomic and transcriptomic data.

---

## Quick start

```bash
git clone https://github.com/[ORG]/[REPO].git
cd [REPO]

# environment (conda)
conda env create -f environment.yml && conda activate vesicle-ei
# ... or pip
python -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt pytest

# everything: tests, data download, analyses, figures, tables, manuscript
./run_all.sh
```

Expected wall time is under 30 minutes on a single CPU core. No GPU, no cluster, no specialised hardware. Peak memory is about 2 GB, dominated by reading the gnomAD constraint table.

---

## Repository layout

```
.
├── run_all.sh                 one command to reproduce everything
├── src/
│   ├── release_model.py       exact moment recursions + Monte-Carlo reference
│   ├── params_literature.py   parameters, each with its source and status
│   ├── identifiability.py     elasticity matrices, null space, compensation
│   ├── identifiability2.py    exact Fisher information, KL, optimal design, MLE
│   ├── analysis_core.py       elasticities, E/I asymmetry, residual geometry
│   ├── ceiling.py             resupply-limited compensation ceiling
│   ├── mpfa.py                variance-mean fluctuation analysis
│   ├── genomics.py            gene-set construction and association tests
│   ├── figstyle.py            publication figure style
│   ├── make_results.py        computes and saves all model results
│   ├── make_genomics.py       computes and saves all human-data results
│   ├── make_figures.py        builds Figures 1-6 (PDF + 600 dpi PNG)
│   ├── build_tables.py        builds Tables 1-4 and Supplementary S1-S4
│   └── build_manuscript.py    resolves citations into numbered references
├── tests/test_model.py        23 tests, each checking a claim in the paper
├── data/
│   ├── download_data.sh       fetches every public dataset
│   └── CHECKSUMS.sha256       checksums of the versions used in the paper
├── results/                   generated: JSON and CSV for every number
├── figs/                      generated: Figures 1-6
└── manuscript/                generated: final manuscript with references
```

---

## The model in brief

A synapse is `N` independent release sites. Each is occupied or empty; an occupied site fuses with probability `p` on an action potential; an empty site refills as a Poisson process with rate `k_rep`. Because the sites are independent and identical, the per-site occupancy obeys an exact scalar recursion,

```
u_{k+1} = (1 - b_k) + u_k (1 - p_k) b_k ,        b_k = exp(-k_rep * dt_k)
```

the quantal count is exactly binomial, `R_k ~ Binomial(N, u_k p_k)`, and the first two moments of the response amplitude follow in closed form. Every quantity in the paper comes from these expressions; the Monte-Carlo routine exists only to verify them, and does so to within sampling error (`test_moments_match_monte_carlo`).

The two structural zeros that make the method work are visible directly in the recursion. The occupancy recursion contains no reference to `N`, so the paired-pulse ratio is blind to the release-site number; and the first response depends on `k_rep` not at all, so its coefficient of variation is blind to the resupply rate. Both are verified over random parameter draws in `test_structural_zeros_hold_everywhere`.

---

## Data

All datasets are public and require no registration. `data/download_data.sh` fetches them and verifies checksums.

| Dataset | Source | Used for |
|---|---|---|
| Gene Ontology annotations and ontology | [current.geneontology.org](https://current.geneontology.org/) | defining the capacity and actuator gene sets |
| gnomAD v4.1 constraint metrics | [gnomAD](https://gnomad.broadinstitute.org/) | coding constraint as a covariate and for matched permutation |
| SFARI Gene | [gene.sfari.org](https://gene.sfari.org/database/human-gene/) | autism risk-gene status |
| PsychENCODE DER-13, DER-16 | [resource.psychencode.org](http://resource.psychencode.org/) | differential expression in autistic cortex; analysed gene universe and covariates |

### Data versions

The Gene Ontology is a rolling release, so its checksum will not match after an update. The release used for the published analysis is recorded in `results/results.json`. gnomAD, SFARI and PsychENCODE are versioned and their checksums are stable.

Every parameter of the release model is taken from a published measurement and is recorded in `src/params_literature.py` together with its source and one of five statuses: *measured*, *derived*, *substituted*, *calibrated* or *excluded*. `results/table_parameters.csv` renders this as Table 1 of the paper. Exactly one parameter is calibrated (the facilitation increment of the inhibitory synapse, fitted to its measured paired-pulse depression), and that measurement is therefore excluded from the validation set.

---

## Reproducing individual results

Each stage can be run on its own once the data are in place:

```bash
export PYTHONPATH=$PWD/src VESICLE_DATA_DIR=$PWD/data \
       VESICLE_RESULTS_DIR=$PWD/results VESICLE_FIGS_DIR=$PWD/figs \
       VESICLE_MS_DIR=$PWD/manuscript

python src/make_results.py      # model, identifiability, ceiling, design
python src/make_genomics.py     # human-data association tests
python src/make_figures.py      # Figures 1-6
python src/build_tables.py      # Tables 1-4, Supplementary S1-S4
python src/build_manuscript.py  # numbered references
```

The random seed is fixed at `20261029` throughout, so every stochastic result (Monte-Carlo verification, simulated fluctuation analyses, permutation nulls, bootstrap intervals, maximum-likelihood recovery) is bit-for-bit reproducible on the pinned dependency versions.

`src/build_manuscript.py` refuses to produce a manuscript if any citation key is absent from the verified reference record set, so an unverifiable citation cannot reach the text.

---

## Tests

```bash
PYTHONPATH=$PWD/src python -m pytest tests/ -q
```

The suite is not a smoke test. Each case checks a statement the paper makes, including:

- the analytic moments agree with site-level simulation at all three synapses;
- the mean-only Jacobian has rank 1 with unit elasticities to `N`, `p` and `q`;
- the full observable vector has rank 4 with condition number below 100;
- `dlogPPR/dlogN` and `dlogCV²/dlog k_rep` vanish over 200 random parameter draws;
- the identity `∂log D/∂log p = u*` holds exactly;
- same-axis compensation erases the lesion to machine precision;
- the two capacity sub-axes are 90 degrees apart to within 1e-9;
- sustained drive never exceeds the resupply ceiling;
- the fitted calcium curve reproduces both anchor points and predicts the independent measurement within one standard deviation.

---

## Extending the analysis

The pieces most likely to be useful on their own:

- `release_model.simulate_moments` — exact moments of any pulse train, `O(pulses)`.
- `identifiability.elasticity_matrix` — the elasticity Jacobian for any observable vector.
- `identifiability.compensate` — exact nonlinear compensation on a chosen actuator.
- `analysis_core.residual_coordinates` — the compensation-invariant residual for any lesion.
- `identifiability2.d_optimal_allocation` — optimal inter-pulse-interval allocation for a trial budget.
- `ceiling.compensable_fraction` — how much capacity loss a given synapse can offset presynaptically.

To apply the residual test to your own recordings you need, per connection, the first-response amplitude distribution and the paired-pulse ratio at a known interval, plus a variance–mean series across external calcium if compensation may be presynaptic. `identifiability2.mle_recovery` shows the sample sizes at which the full parameter vector is recovered without bias.

To test a different homeostatic set point, replace the `control_variable` argument of `compensate`; the null-space geometry is recomputed automatically.

---

## Known limitations

These are stated in the paper and repeated here so that users of the code are not misled.

- Release sites are assumed independent and statistically identical with a single quantal size. Heterogeneity in release probability within an active zone is documented and would reduce the information available about the site number, though it leaves the structural zeros intact.
- Parameters come from rodent preparations at three identified synapses and from different laboratories. The recovery time constant of the hippocampal excitatory synapse is substituted from the neocortical measurement; this is flagged in Table 1 and conclusions were checked against the alternative.
- The model predicts a failure probability of 0.034 at the neocortical layer-5 connection against a measured 0.14. Inverting the failure-rate expression implies about 3.2 effective release sites rather than 5.5 anatomical contacts. The discrepancy is reported rather than resolved, and no conclusion depends on which value is used.
- The transcriptomic data are bulk cortex and cannot separate excitatory from inhibitory neurons. Cell-type-resolved data are the most valuable next input.
- Differential expression cannot by itself distinguish a primary lesion from a compensatory response. That is the point of the paper, not a defect of the analysis.

---

## Licence and citation

Code is released under the MIT Licence (see `LICENSE`). The public datasets retain the licences of their originating consortia.

If you use this code, please cite both the software (see `CITATION.cff`) and the paper.
