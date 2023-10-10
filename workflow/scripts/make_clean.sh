#!/bin/bash
# ---------------------------
# Clean all outputs and intermediate files to prep for new Snakemake run
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

rm -rf logs
rm -rf results/feature_engineering/kmer_counts/*
rm results/snakemake_dag.png
rm data/all_kmer_counts.csv
rm data/merged_data.csv

# Snakemake status files
