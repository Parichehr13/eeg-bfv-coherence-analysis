# Multi-Band EEG Power Variability and Coherence with BFV2

This repository is a compact MATLAB analysis project for studying whether slow fluctuations in EEG band power covary with slow fluctuations in cerebral blood flow velocity (`BFV2`).

The project is intentionally positioned as an exploratory signal-processing study, not as a finished biomarker claim. Its strongest value is that it now runs reproducibly from the repository root, exports structured outputs, and includes a same-channel control analysis to reduce over-interpretation of band comparisons.

## Why this project is worth keeping

- The underlying question is scientifically reasonable: do slow EEG band-power fluctuations align with slow BFV oscillations?
- The dataset supports more than a single delta-band script because it contains multiple EEG channels (`F4C4`, `P3O1`, `P4O2`) plus `BFV2`.
- The repo is small enough to stay readable, but rich enough to demonstrate signal-processing judgment, reproducibility, and honest methodological framing.

## What the pipeline now does

The main analysis uses 2-second EEG epochs to build one power value per epoch for each band:

- `delta`: 0.5-4 Hz
- `theta`: 4-8 Hz
- `alpha`: 8-13 Hz
- `beta`: 13-30 Hz

For each epoch and band:

1. Welch PSD is computed inside the epoch.
2. Band power is obtained by integrating the PSD over the band limits.
3. The resulting band-power time series is compared with `BFV2` using magnitude-squared coherence.
4. Coherence is summarized in the low-frequency range `0.02-0.15 Hz`.

## Control analysis

The repository now exports two strategies:

- `primary`: delta/theta/beta from `F4C4`, alpha from a posterior channel when available (`P3O1` preferred, then `P4O2`)
- `same_channel_control`: all bands from `F4C4`

This control does not make the analysis inferential, but it helps answer an important question honestly:

Is an apparent advantage of alpha partly due to using a posterior channel rather than the band itself?

## Repository structure

```text
.
|-- data/
|   `-- dataset09.mat
|-- figures/
|   |-- fig01_example_channels.png
|   |-- fig02_band_power_variability.png
|   |-- fig03_coherence_with_bfv2.png
|   `-- fig04_strategy_comparison.png
|-- results/
|   |-- analysis_outputs.mat
|   |-- strategy_comparison.csv
|   |-- summary_primary.csv
|   `-- summary_same_channel_control.csv
|-- src/
|   |-- analyzeStrategy.m
|   |-- computeBandPowerVariability.m
|   |-- defaultConfig.m
|   |-- epochSignal.m
|   |-- exportProjectOutputs.m
|   `-- loadDataset.m
|-- LICENSE
|-- main.m
`-- README.md
```

## How to run

Open MATLAB in the repository root and run:

```matlab
main
```

No manual `load(...)` step is required. The script reads `data/dataset09.mat`, saves figures to `figures/`, and writes CSV and MAT outputs to `results/`.

## Execution status

This refactored pipeline was batch-run successfully in this environment with MATLAB `R2024b Update 6` on April 22, 2026.

What was verified by execution:

- MATLAB launches successfully.
- `data/dataset09.mat` loads correctly.
- the analysis runs end-to-end from `main.m`
- figures are saved
- CSV and MAT outputs are exported

What is still only supported as interpretation, not proof:

- whether any coherence pattern generalizes beyond this recording
- whether the strongest band reflects physiology rather than recording-specific structure
- whether coherence implies directional or causal coupling

## Scientific limits

- This is a single-recording exploratory analysis, not a population study.
- Coherence quantifies frequency-domain association, not causality.
- The primary strategy uses different channels for different bands, so its ranking is a band-plus-channel comparison.
- The same-channel control helps with interpretation but is not a full null model or statistical significance test.

## Why this is stronger for a CV now

The repository is more defensible because it demonstrates:

- reproducible execution
- cleaner MATLAB engineering
- explicit output artifacts
- a control analysis that addresses a real interpretation issue
- honest scope without exaggerated novelty
