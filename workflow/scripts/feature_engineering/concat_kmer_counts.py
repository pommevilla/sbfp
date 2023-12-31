#!/usr/bin/env python
# ---------------------------
# Combines all k-mer count files output from kmc into one csv
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------
import pandas as pd


def pivot_and_rename_kmer_counts(kmer_count_file: str):
    """
    Read kmer count file into pandas pd dataframe and pivot table with SRA accession as index

    input: kmer_count_file (str) - path to kmer count file
    """

    sra_accession = os.path.basename(
        kmer_count_file.removesuffix(f"_{snakemake.params.kmer_length}mers.txt")
    )

    # Currently only doing the first 1000 rows. Will remove this in production.
    df = pd.read_csv(
        kmer_count_file, sep="\t", header=None, names=["kmer", "count"], nrows=1000
    )
    df["genome"] = sra_accession
    df = df.pivot(index="genome", columns="kmer", values="count")

    return df


if __name__ == "__main__":
    import os

    all_kmer_count_files = snakemake.input.input_kmer_count_files

    df = pd.concat(
        (pivot_and_rename_kmer_counts(fin) for fin in all_kmer_count_files)
    ).fillna(0)

    df.to_csv(snakemake.output[0])
