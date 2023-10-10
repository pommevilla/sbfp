

configfile: "config/config.yml"
import glob
import os

genome_files = glob.glob(f"{config['data_prep']['genome_directory']}/*")
genome_names = [os.path.basename(gfile) for gfile in genome_files]

# If directories don't exist, make them
if not os.path.exists(config['data_prep']['kmc_temp_dir']):
    os.makedirs(config['data_prep']['kmc_temp_dir'])
