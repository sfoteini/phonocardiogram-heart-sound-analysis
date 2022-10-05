# Automatic heart sounds analysis using Empirical Mode Decomposition and Higher-Order Spectra

This repository is the official implementation of [Automatic heart sounds analysis using Empirical Mode Decomposition and Higher-Order Spectra](/paper.pdf).

**Authors**: Foteini Savvidou, Stavros Tsimpoukis, Stavros Filosidis, Chrysoula Psyrouki, Konstantinos Barmpounakis, Leontios Hadjileontiadis

## Abstract

To be added soon

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
