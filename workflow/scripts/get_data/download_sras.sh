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
      i ) sras_to_download="$OPTARG" ;;
      n ) num_records="$OPTARG" ;;
      ? ) helpFunction ;; 
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

if [ -z "$num_records" ] 
then
   num_records=5
fi

echo "SRA records file: $sras_to_download"
echo "Number of records to fetch: $num_records"

# Only fetching the top 5 by default
head -n $num_records $sras_to_download | while read -r sra_record
do
   echo "    $sra_record"
   prefetch $sra_record -O data/sra_prefetch
done 