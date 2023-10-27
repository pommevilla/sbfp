# Salmonella biofilm formation prediction

## Workflow DAG

![](results/snakemake_dag.png)

## Running the pipeline

* Edit the config file in the indicated places
* Install `snakemake`. A bare conda/mamba environment is recommended (ie., created with `mamba craete -c conda-forge -c bioconda -n snakemake snakemake`)
* Run the pipeline with `snakemake --use-conda -c`



## To Dos

- [x] Parameterize k for k-mer counting
- [ ] Add AA k-mer counting
- [ ] Feature selection
- [x] Configure for slurm
- [ ] Update XGBoost version to avoid deprecation warnings
    - See: https://github.com/dmlc/xgboost/issues/9543
- [x] Phylogenetic tree building
