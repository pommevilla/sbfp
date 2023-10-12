
configfile: "config/config.yml"
import glob
import os

genome_directory = config['directories']['genome_directory']
genome_file_extensions = ['fa', 'fna', 'fasta', 'fastq']

genome_files = []
for ext in genome_file_extensions:
    genome_files.extend(glob.glob(f"{genome_directory}/*.{ext}"))

genome_names = [os.path.basename(gfile) for gfile in genome_files]

# If directories don't exist, make them
if not os.path.exists(config['directories']['kmc_temp_dir']):
    os.makedirs(config['directories']['kmc_temp_dir'])
