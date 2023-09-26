#!/bin/bash
# ---------------------------
# Download FASTQ files from SRA record numbers using SRA toolkit
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

helpFunction()
{
   echo ""
   echo "Usage: $0 -i sras"
   echo -e "\t-i List of SRAs to download, each on a newline"
   exit 1 # Exit script after printing help
}

while getopts "i:" opt
do
   case "$opt" in
      i ) sras_to_download="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

if [ -z "$sras_to_download" ] 
then
   echo "Some or all of the parameters are empty."
   helpFunction
fi

if [ ! -f "$sras_to_download" ]; then
    echo "$sras_to_download does not exist. Are you in the right directory?"
    helpFunction
fi

echo "First arg: $sras_to_download"

# Prefetch
echo "Prefetching..."
head -n 2 $sras_to_download | while read -r sra_record
do
   echo "    $sra_record"
   prefetch $sra_record
done 

# Extract
echo "Extracting..."
head -n 2 $sras_to_download | while read -r sra_record
do
   echo "    $sra_record"
   fastq-dump --outdir data/genomes --gzip --skip-technical  --readids --read-filter pass --dumpbase --split-3 --clip $sra_record/$sra_record.sra
done

# k-mer counting
echo "Counting k-mers..."

head -n 2 $sras_to_download | while read -r sra_record
do
   echo "    $sra_record"
   kmc -k10 data/genomes/${sra_record}_pass_1.fastq.gz 10mers kmc_temp
   kmc_tools transform 10mers dump ${sra_record}_10mers.txt
done