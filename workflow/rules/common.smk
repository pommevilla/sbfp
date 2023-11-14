
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

# AA kmer lengths
AA_KMER_LENGTHS = config['parameters']['aa_kmer_lengths']

# Blast database suffixes
BLAST_DB_SUFFIXES = ['ndb', 'nhr', 'nin', 'njs', 'not', 'nsq', 'ntf', 'nto']


######## Functions ########
def get_mem_mb(wildcards, attempt, base_mb=16000):
    return base_mb + (attempt * 8000)

def determine_mercat_threads(wildcards, attempt, base_threads=8):
    return base_threads + (attempt * 8)

# Can't do this as a lambda inside the rule because of the way Snakemake parses wildcards
def determine_mercat_min_count(wildcards):
    return 5 if int(wildcards.aa_kmer_length) >= 10 else 10
