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
      i ) sras_to_dump="$OPTARG" ;;
      n ) num_records="$OPTARG" ;;
      ? ) helpFunction ;; 
   esac
done

if [ -z "$sras_to_dump" ] 
then
   echo "Some or all of the parameters are empty."
   helpFunction
fi

if [ ! -f "$sras_to_dump" ]; then
    echo "$sras_to_dump does not exist. Are you in the right directory?"
    helpFunction
fi

if [ -z "$num_records" ] 
then
   num_records=2
fi

echo "SRA records file: $sras_to_dump"
echo "Number of records to fetch: $num_records"

# Extract
echo "Extracting..."
head -n $num_records $sras_to_dump | while read -r sra_record
do
   echo "    $sra_record"
   fastq-dump --outdir data/genomes/$sra_record --gzip --skip-technical \
      --readids --read-filter pass --dumpbase --split-3 --clip \
      data/sra_prefetch/$sra_record/$sra_record.sra
done
