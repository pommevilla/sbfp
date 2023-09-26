#!/bin/bash
# ---------------------------
# Clean outputs to prep for new run
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

rm *kmc*
rm data/genomes/*

head -n 2 data/sras.txt | while read -r sra_record
do
    rm -rf $sra_record
done

rm *mers.txt