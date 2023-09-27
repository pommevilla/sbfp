#!/bin/bash
# ---------------------------
# Prefetch FASTQ files from SRA record numbers using SRA toolkit
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

helpFunction()
{
   echo ""
   echo "Usage: $0 -i sras (-n num_records)"
   echo -e "\t-i List of SRAs to dump, each on a newline"
   echo -e "\t-n Number of records to fetch (default: 2)"
   exit 1 
}

while getopts "i:n:" opt
do
   case "$opt" in
      i ) sra_records="$OPTARG" ;;
      n ) num_records="$OPTARG" ;;
      ? ) helpFunction ;; 
   esac
done

if [ -z "$sra_records" ] 
then
   echo "Some or all of the parameters are empty."
   helpFunction
fi

if [ ! -f "$sra_records" ]; then
    echo "$sra_records does not exist. Are you in the right directory?"
    helpFunction
fi

if [ -z "$num_records" ] 
then
   num_records=5
fi

echo "SRA records file: $sra_records"
echo "Number of records to fetch: $num_records"

echo "Counting k-mers..."

head -n $num_records $sra_records | while read -r sra_record
do
   echo "    $sra_record"
   kmc -k15 data/genomes/${sra_record}/${sra_record}_pass_1.fastq.gz data/kmc_temp/15mers data/kmc_temp
   kmc_tools transform data/kmc_temp/15mers dump data/kmer_counts/${sra_record}_15mers.txt
done