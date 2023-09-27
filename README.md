# Salmonella biofilm formation prediction

## Workflow DAG

![](results/snakemake_dag.png)

## To Dos

- [ ] Parameterize k for k-mer counting
- [ ] Add AA k-mer counting
- [ ] Feature selection
- [ ] Configure for slurm
- [ ] Set up config file
- [ ] Take off testing parameters for:
    - [ ] Number of SRAs to fetch at the beginning of the pipeline (currently using 2)
    - [ ] Number of k-mers used in the final k-mer count table (currently using 500)