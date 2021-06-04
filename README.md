# Description

This package implements the parameter fitting pipeline for the NTD
trachoma model. Starting from geostatistical infection prevalence data
and MDA data, this pipeline

1. selects IUs according with same scenario and similar observed mean infectio prevalence value,
2. estimates distribution of parameters for each selected IU using the Adaptive Multiple Importane Sampling (AMIS) algorithm,
3. for each selected IUs, sample `N` parameters and resimulate model
   until 2020, saving the necessary data to run the model forward in
   time from 2020.

This package does not implement the AMIS algorithm, both rather depends on the trachomAMIS package (<https://github.com/OxfordRSE/trachomAMIS>).

Table of contents
-----------------------------------------

- [Installation](#installation)
- [Usage](#usage)
  - [Input data](#input-data)
  - [Output data](#output-data)
- [Pipeline Overview](#pipeline-overview)
  - [IU groups](#iu-groups)
  - [Estimation of the parameter distribution](#estimation-of-the-parameter-distribution)
  - [Resampling](#resampling)

# Installation

1. Install pipeline package and trachomAMIS

```R
devtools::install_github("OxfordRSE/trachomAMIS")
devtools::install_github("OxfordRSE/NTDMC_trachoma_pipeline")
```
2. Clone NTD trachoma model and install it

```shell
git clone https://github.com/ArtRabbitStudio/ntd-model-trachoma.git
python3 -m pip install ntd-model-trachoma/
```

# Usage

This package exports a function `dopipeline` that executes the
pipeline for a given group of IUs with same scenario and similar
values of mean infection prevalence, typically within within 10% of
each other (see [IU groups](#iu-groups).

```R
trachomapipeline::dopipeline("/path/to/parameters.yaml", group_number)
```

If there are `G` such groups, the pipeline should be run for each one,
`e.g.` with `group_number` ranging from `1` to `G`.  This is typically
done by submitting an array of jobs on a computer cluster. For instance, using SLURM

```
# batch.sh
#!/bin/bash
#SBATCH --nodes=1
#SBATCH -a 1-200

module load gnu7/7.3.0
module load R

R --vanilla < run_pipeline.R > std_out
```

```R
## run_pipeline.R

group_number <- as.numeric(Sys.getenv('SLURM_ARRAY_TASK_ID'))

trachomapipeline::dopipeline("input.yaml", group_number)
```

```shell
sbatch batch.sh
```

Pipeline parameters are desribed in a YAML file. The following example
lists all parameters along with example values:

```yaml
data_file: "./data/FinalData.csv" # Geostatistical data
nsamples_map: 3000 # Nb of samples for sampling prevalence map
nsamples: 100 # Number of parameters samples at each AMIS iteration
delta: 5 # delta parameter for AMIS
T: 100 # Maximum number of AMIS iterations
target_ess: 250 # Target Effective Sample Size
nsamples_resample: 200 # Number of parameter values to resample
resample_path: "./output" # Output path
python: "/usr/bin/python3" # Path to python binary (optional)
```

Each of the above must be specified, expect the `python` entry which
is optional. If unspecified, the pipeline will defaut to whichever
python version is returned by `Sys.which("python3")`.

## Input data

Keyword `data` in the YAML parameter file should point to a csv file
describing geostastical prevalence and MDA data. It should conform to
the following structure:

```
"IUCodes","Logit","Sds","start_MDA","last_MDA","Scenario"
"ETH18551",-1.814302776,0.243590266,2008,2017,36
"ETH18604",-1.28066311,0.255922043,2008,2019,28
"ETH18612",-0.935541745,0.243342198,2007,2012,45
...
```

The order of columns does not matter, and more columns are
possible. However the following _must_ be present:

- `IUCodes`: The code for the implementation unit
- `Logit`, `Sds`: Prevelane geostastics (logit and standard deviation values).
- `start_MDA`: Year of first MDA
- `last_MDA`: Year of last MDA
- `Scenario`: The scenario indentifier. Each scenario corresponds to a
  different (`start_MDA`, `last_MDA`) pair.

## Output data

The location of output data is controlled by the pipeline parameter
`resample_path`. This should be the path to a directory. If the
directory does not exist, it will be created. In the following we
refer to this directory as the *output directory*.

Within the output directory, the output data is organised according to
the following structure:

- `prevalence_maps/`: Contains the sampled prevalence maps, see
  [Prevalence map sampling](#prevalence-map-sampling). This is a csv
  file containing a `NxM` matrix where `N` is the number of IUs in the
  IU group and `M` the number of samples per IU.
- `sampled_parameters/`: Contains the values and weights sampled by
  the AMIS. See [Sampled Parameters](#sampled-parameters) below.
- `model_input/`: The trachoma model input files used for the
  resampling step. One file per IU, named after the IU code (_e.g._
  `ETH18544`)
- `model_output/`: The trachoma model output files generated at the
  resampling step. For each IU, you can find:
  - `OutputPrev_<iucode>.csv`: The simulated prevalence over time.
  - `InfectFilePath_<iucode>.csv`: The infection path.
  - `OutputVals_<iucode>.csv`: A Python pickle file representing the
    final state of the simulation.
- `mda_files/`: The MDA files used at the resampling step. One file per IU, named after the IU code.
- `ess_not_reached`: Contains output files for IUs in groups for which
  the AMIS algorithm did not reach the target effective sample size.

### Sampled parameters

Within the output directory, directory `sampled_parameters/` contains
csv files containing the estimated parameter distribution for
IUs. There is one file per IU group.  Each csv file has the following
structure

```
"seeds","beta","sim_prev","ETH18551","ETH18604","ETH18612"
1,0.146260174119379,0,0,0,0
2,0.162822582712397,4.08921933085502,2.37479503835842e-06,0.000102643531883294,0.000126708295890263
3,0.153081849898444,6.69291338582677,9.843187594714e-05,0.000383887955739902,0.000642116478978414
4,0.13934580461937,0,0,0,0
...
```

There are 3 IUs in this particular IU group. Their code is "ETH18551",
"ETH18604" and "ETH18612", respectively.  The columns are:

- `seeds`: The random generator seed when resampling these IUs.
- `beta`: The transmission parameter value.
- `sim_prev`: The simulated infection prevalence value.

The remaining columns correspond to the weight corresponding to each
parameter value, for each IU in the IU group.

### IU groups that do not reach the target ESS

In this event that the AMIS for a given IU group does not reach the
target Effective Sample Size (ESS) (`target_ess` pipeline parameter), the
estimated parameter distribution, model input/output files and MDA
files are saved in a separate directory `ess_not_reached/`, located
_inside_ the output directory. The `ess_not_reached` directory is
structured in the same way as the output directory, _i.e._ with output
files distributed across directories `ess_not_reached/model_input`,
`ess_not_reached/model_output` ... etc.

```
<output-dir>/
  sampled_parameters/
  prevalence_maps/
  model_output/
  ...
  ess_not_reached/
    model_output/
	model_input/
	...
```

The file `ESS_NOT_REACHED.txt` provides a list of IUs for which the
ESS was not reached. It is located at the root of the output
directory.

# Pipeline overview
  
## IU groups

Estimating the parameter disctribution works at IUs works best if IUs
are grouped by mean observed prevalence value. **A prevalence group
spans a range of 10% prevalence**. For example, implementation units
with an observed 2019 mean prevalence between 0% and 10% fall in group
1, whilst IUs with value between 10% and 20% fall in group 2.

Note that all IUs leading to a mean prevalence above 60% are combined
into a single group (group 7). These IUs are not processed.

Prevalence group are then further split according to scenarios. A IU
group contains IUs within the same prevalene group with the same
scenario, *i.e.* the same MDA years.

A call to `dopipeline` performs the fitting pipeline for a single IU
group, according to the `group_number` argument.

## Estimation of the parameter distribution

One all IUs in the current IU group have been identified, the
parameter distribution for each IU is estimated using the Adaptive
Multiple Importance Sampling (AMIS) algorithm.

### Prevalence map sampling

The AMIS relies on a prevalence map, which consists of an ensemble of
sampled prevalence values for each IU. The prevalence map is sampled
from the `Logit` and `Sds` values for each IU in the data (see
[initial data](#initial-data)). The number of prevalence samples to
draw per IU is controlled by the parameter `nsamples_map`.

The sampling prevalence map is written on disk, see [output
data](#output-data).

### Parameter estimation using AMIS

The AMIS algorithm estimates the distribution of the transmission
parameter for each IU in the group.  For a given IU group, the AMIS is
performed using the `trachomAMIS` package's `amis` function. It
outputs parameters values and corresponding statistical weights for
IUs in the group.

```R
params_and_weights <- trachomAmis(prevalence_map, model_func, amis_params)
```

The argument `model_func` is a function wrapping the NTD trachoma
model (Python).  It is assumed that the NTD trachoma modeled can be
imported by the python binary specified in the input YAML file. See
[Installation](#installation).


## Resampling

The final step in the pipeline is the simulation of the transmission
model until 2020, for an ensemble of parameter values sampled from the
parameter distribution estimated at the previous step.

The number of parameter values to sample from the estimated parameter
distribution is controlled by pipeline parameter `nsamples_resample`.

For each one of the `nsamples_resample` sampled parameter values, the
NTD trachoma model is simulation until 2020. The start year for these
simulations is common to all IUs: it is the year before the minimum
first MDA year across all IUs described in the initial data.

For each simulation, the following data is saved:
- The trachoma model input file (`<output-dir>/model_input/InputBet_<iucode>.csv`)
- The trachoma model output files:
  - `OutputPrev_<iucode>.csv`: The simulated prevalence over time.
  - `InfectFilePath_<iucode>.csv`: The infection path.
  - `OutputVals_<iucode>.csv`: A Python pickle file representing the
    final state of the simulation.
- The MDA file describing the start year, end year and MDA first and
  last year (`<output-dir>/mda_files/InputMDA_<iucode>.csv`
