#!/usr/bin/env python
# ---------------------------
# Combines all k-mer count files output from kmc into one csv
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------
import pandas as pd

if __name__ == "__main__":
    phenotypes = pd.read_csv(snakemake.input.phenotypic_data, index_col=0)
    kmer_counts = pd.read_csv(snakemake.input.all_kmer_counts, index_col=0)

    merged = pd.merge(
        phenotypes, kmer_counts, left_index=True, right_index=True
    )


    print(phenotypes)
    print(kmer_counts)
    print(merged)
    
    print(f"Pheno size: {phenotypes.shape}")
    print(f"kmer size: {kmer_counts.shape}")
    print(f"merged size: {merged.shape}")

    merged.to_csv(snakemake.output.merged_data, index_label="genome")
