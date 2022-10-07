# Automatic heart sounds analysis using Empirical Mode Decomposition and Higher-Order Spectra

This repository is the official implementation of [Automatic heart sounds analysis using Empirical Mode Decomposition and Higher-Order Spectra](/paper.pdf).

**Authors**: Foteini Savvidou, Stavros Tsimpoukis, Stavros Filosidis, Chrysoula Psyrouki, Konstantinos Barmpounakis, Leontios Hadjileontiadis

## Abstract

Cardiovascular diseases (CVD) are one of the leading causes of morbidity and mortality in the world. The diagnosis of heart disorders is a useful but usually difficult task. Phonocardiogram (PCG) signals contain valuable information about the mechanical function and state of the human heart that is useful in the diagnosis of such diseases. The present work proposes a computer-aided technique based on the analysis of the fundamental heart sounds (FHS), i.e., the first heart sound (S1) and the second heart sound (S2), using Empirical Mode Decomposition (EMD) and Higher-Order Spectra (HOS). EMD allows the decomposition of the PCG signals into several oscillatory components (Intrinsic Mode Functions, IMF) increasing thus the observability of the FHS. By employing a kurtosis-based criterion, we located the IMFs that contain relevant information regarding S1 and S2. On those IMFs, we estimated the bispectrum of FHS and explored features derived from the magnitude of the bispectrum for the quantification of heart conditions (normal and abnormal). Statistical tests were used to facilitate feature selection and the derived features were fed to a decision-tree-based ensemble model classifier (XGBoost) for the distinction of normal and abnormal heart sounds. Experimental results have shown that, overall, the XGBoost classifier determines the heart condition in a percentage of 82% balanced accuracy. Moreover, cepstral analysis was carried out for the identification of the periodicity of a heart cycle and the acquisition of the impulse response that is affiliated with the heart sound signals (normal and abnormal). The results suggest that the bispectral and cepstral analysis of the PCG signals can facilitate the diagnosis of heart disorders in everyday clinical practice.

**Index Terms**: Empirical mode decomposition, Bispectrum, Cepstrum, Phonocardiogram, Heart sounds.

## Requirements

Install the following MATLAB toolboxes:
* Signal Processing Toolbox
* Statistics and Machine Learning Toolbox

## Directory structure

```
phonocardiogram-heart-sound-analysis/
├── AUTHORS.md                                              # authors of the paper
├── LICENSE                                                 # license for the project
├── README.md                                               # overview of the project
├── main.m                                                  # contains all code of the project
├── paper.pdf                                               # manuscript describing the results
├── annotations/                                            # annotation files used in this project
│   └── hand_corrected/
│       ├── training-a_StateAns/
│       │   └── 📜 409 files
│       ├── training-b_StateAns/
│       │   └── 📜 490 files
│       ├── training-c_StateAns/
│       │   └── 📜 31 files
│       ├── training-d_StateAns/
│       │   └── 📜 55 files
│       ├── training-e_StateAns/
│       │   └── 📜 2054 files
│       └── training-f_StateAns/
│           └── 📜 114 files
├── data/                                                   # PCG recordings used in this project
│   ├── training-a/
│   │   └── 📜 1225 files
│   ├── training-b/
│   │   └── 📜 987 files
│   ├── training-c/
│   │   └── 📜 69 files
│   ├── training-d/
│   │   └── 📜 118 files
│   ├── training-e/
│   │   └── 📜 4282 files
│   └── training-f/
│       └── 📜 235 files
├── functions/                                              # contains all functions of the project
│   └── 📜 functions of the project
├── lib/                                                    # contains the HOSA toolbox
│   └── hosa/
│       └── 📜 functions of the HOSA toolbox
├── output/                                                 # results of the analysis
│   ├── data/
│   │   └── 📜 files produced by the MATLAB script
│   └── figures/
│       └── 📜 figures produced by the MATLAB script
└── processed_data/                                         # intermediate files from the analysis
    └── updated_appendix.csv

```
* The `data` directory contains the PCG recordings analyzed during the current study. The PCG recordings are available in the [PhysioNet repository](https://physionet.org/content/challenge-2016).
* The `annotations` directory contains the annotations files for the PCG recordings. The annotation files are available in the [PhysioNet repository](https://physionet.org/content/challenge-2016).

## Set up

1. Download the dataset analyzed in the present study from the [PhysioNet repository](https://physionet.org/content/challenge-2016).
2. Extract the PCG recordings and annotation files in the `data` and `annotations` directory respectively.
3. Run the `main.m` script. The simulated experiments are divided into sections.
