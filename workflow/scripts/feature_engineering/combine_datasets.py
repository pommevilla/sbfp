#!/usr/bin/env python
# ---------------------------
# Combines all k-mer count files output from kmc into one csv
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------
import pandas as pd
import numpy as np

if __name__ == "__main__":
    # phenotypes = pd.read_csv(snakemake.input.phenotypic_data, index_col=0)
    kmer_counts = pd.read_csv(snakemake.input.all_kmer_counts, index_col=0)

    # merged = pd.merge(
    # phenotypes, kmer_counts, left_index=True, right_index=True
    # )

    # Assign fake groups to the dataframe. A has lower values, B has higher values.
    kmer_counts["group"] = ["A"] * 50 + ["B"] * 49

    # Feature 0 - 0 < A, B < 100
    # This feature is our baseline and has no predictive power at all
    kmer_counts["feature_0"] = np.random.randint(0, 100, 99)

    # Feature 1 - 0 < A < 75, 25 < B < 100
    # Still a lot of noise, but weakly predictive of group
    kmer_counts["feature_1"] = np.where(
        kmer_counts["group"] == "A",
        np.random.randint(0, 75, 99),
        np.random.randint(25, 100, 99),
    )

    # Feature 1 - 0 < A < 50, 50 < B, 100
    # Less noise, clear separation
    kmer_counts["feature_2"] = np.where(
        kmer_counts["group"] == "A",
        np.random.randint(0, 50, 99),
        np.random.randint(50, 100, 99),
    )

    # Feature 2 - 0 < A < 25, 75 < B < 100
    # Super predictive
    kmer_counts["feature_3"] = np.where(
        kmer_counts["group"] == "A",
        np.random.randint(0, 25, 99),
        np.random.randint(75, 100, 99),
    )

    # print(phenotypes)
    print(kmer_counts)
    # print(merged)

    # print(f"Pheno size: {phenotypes.shape}")
    print(f"kmer size: {kmer_counts.shape}")
    # print(f"merged size: {merged.shape}")

    # merged.to_csv(snakemake.output.merged_data, index_label="genome")
    kmer_counts.to_csv(snakemake.output.merged_data, index_label="genome")
