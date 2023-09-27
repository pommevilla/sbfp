#!/bin/bash
# ---------------------------
# Clean all outputs and intermediate files to prep for new Snakemake run
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

rm -rf data/genomes/*
rm data/kmer_counts/*
rm data/kmc_temp/*
rm -rf data/sra_prefetch/*
rm data/all_kmer_counts.csv

# Snakemake status files
rm .fastqs_dumped
rm .sras_fetched
rm .kmers_counted