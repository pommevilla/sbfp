# Salmonella biofilm formation prediction

## Workflow DAG

![](results/snakemake_dag.png)

## Running the pipeline

* Edit the config file in the indicated places
* Install `snakemake`. A bare conda/mamba environment is recommended (ie., created with `mamba craete -c conda-forge -c bioconda -n snakemake snakemake`)
* Run the pipeline with `snakemake --use-conda -c`



## To Dos

- [ ] Feature selection
- [ ] Add tree building to pipeline
