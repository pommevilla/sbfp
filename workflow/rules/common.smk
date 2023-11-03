
configfile: "config/config.yml"
import glob
import os

genome_directory = config['directories']['genome_directory']
genome_file_extensions = ['fa', 'fna', 'fasta', 'fastq']

genome_files = []
for ext in genome_file_extensions:
    genome_files.extend(glob.glob(f"{genome_directory}/*.{ext}"))

GENOME_NAMES = [os.path.basename(gfile) for gfile in genome_files]

# If directories don't exist, make them
if not os.path.exists(config['directories']['kmc_temp_dir']):
    os.makedirs(config['directories']['kmc_temp_dir'])

# Nucleotide kmer length
NUCL_KMER_LENGTH = config['parameters']['nucl_kmer_length']

# Blast database suffixes
BLAST_DB_SUFFIXES = ['ndb', 'nhr', 'nin', 'njs', 'not', 'nsq', 'ntf', 'nto']
