# Multi-Band EEG Power Variability and Coherence with BFV2

Compact MATLAB analysis of EEG band-power variability and its low-frequency coherence with cerebral blood flow velocity (`BFV2`).

The repository studies whether slow fluctuations in EEG band power show frequency-domain association with slow fluctuations in `BFV2` within a single physiological recording. It is structured as a reproducible exploratory analysis rather than a large software framework.

## Project overview

The dataset includes:

- `F4C4`: frontal EEG channel
- `P3O1`, `P4O2`: posterior EEG channels
- `BFV2`: cerebral blood flow velocity
- `Fs_EEG = 512 Hz`
- `Fs_BFV = 0.5 Hz`

The analysis converts EEG into one band-power value per 2-second epoch, producing slow power-variability signals that can be compared with `BFV2` on the same effective time scale.

Bands analyzed:

- `delta`: 0.5-4 Hz
- `theta`: 4-8 Hz
- `alpha`: 8-13 Hz
- `beta`: 13-30 Hz

## Analysis pipeline

1. EEG channels are segmented into non-overlapping 2-second epochs.
2. Welch PSD is estimated within each epoch.
3. Band power is obtained by integrating the PSD over each frequency band.
4. Epoch-wise band power values are assembled into slow power-variability time series.
5. Magnitude-squared coherence is computed between each band-power variability signal and `BFV2`.
6. Coherence is summarized over `0.02-0.15 Hz` using peak coherence, peak frequency, mean coherence, and area under the coherence curve.

## Control analysis

Two channel-selection strategies are exported:

- `primary`: delta, theta, and beta from `F4C4`; alpha from a posterior channel when available (`P3O1` preferred, then `P4O2`)
- `same_channel_control`: all bands from `F4C4`

The control analysis is included to make band comparisons easier to interpret when alpha is estimated from a different channel than the other bands.

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

The script loads `data/dataset09.mat`, runs the full analysis, saves figures to `figures/`, and writes tabular and MAT outputs to `results/`.

Tested locally with MATLAB `R2024b`.

## Outputs

The repository exports:

- example channel plots
- band-power variability plots
- coherence plots for the primary strategy
- a strategy-comparison figure
- CSV summaries for the primary and control analyses
- a MAT file containing the full exported analysis state

## Scientific limits

- This is a single-recording exploratory analysis, not a population study.
- Coherence measures frequency-domain association and should not be interpreted as causality.
- The primary strategy mixes channel location with band selection, so it should be interpreted as a band-plus-channel comparison.
- The same-channel control improves interpretability but is not a formal null model or significance test.

## Possible extensions

- Add a simple surrogate or permutation-based null analysis for coherence.
- Compare additional same-channel and cross-channel strategies.
- Apply the pipeline to multiple recordings if comparable datasets are available.
