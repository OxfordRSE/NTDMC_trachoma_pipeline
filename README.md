# Installation

1. Install pipeline package

```R
	devtools::install_github("OxfordRSE/NTDMC_trachoma_pipeline")
```
2. Clone trachoma model

```shell
git clone https://github.com/ArtRabbitStudio/ntd-model-trachoma.git
```
3. Create python virtual environment

```shell
python3 -m venv .venv
source .venv/bin/activate
```
4. Install model 

```shell
python3 -m pip install ntd-model-trachoma/
```

# Usage

```R
> trachomapipeline::dopipeline("/path/to/parameters.yaml")
```

Function `dopipeline` expects the path to a YAML file describing the parameters:

```yaml
data_file: "./data/FinalData.csv" # Geostatistical data
nsamples_map: 3000 # Nb of samples for sampling prevalence map
nsamples: 100.0 # Number of parameters samples at each AMIS iteration
delta: 5 # delta parameter for AMIS
T: 5 # Maximum number of AMIS iterations
target_ess: 250 # Target Effective Sample Size
nsamples_resample: 200 # Number of parameter values to resample
resample_path: "./output" # Output path
```
