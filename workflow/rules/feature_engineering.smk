# ---------------------------
# Rules about feature extraction/engineering
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

# Generates kmer count files for individual genomes
rule count_nucl_kmers:
    output:
        "results/feature_engineering/kmer_counts/{nucl_kmer_length}mers/{genome_name}_{nucl_kmer_length}mers.txt"
    params:
        genome_directory=config["directories"]["genome_directory"],
        kmer_length=config["parameters"]["nucl_kmer_length"]
    log:
        err="logs/count_nucl_kmers/{genome_name}/count_kmers_{genome_name}_{nucl_kmer_length}.err",
        out="logs/count_nucl_kmers/{genome_name}/count_kmers_{genome_name}_{nucl_kmer_length}.out"
    conda:
        "../envs/kmc.yml"
    shell:
        """
        kmc -k{params.kmer_length} -fm {params.genome_directory}/{wildcards.genome_name} \
            data/kmc_temp/{params.kmer_length}mers_{wildcards.genome_name} \
            data/kmc_temp 1> {log.out} 2> {log.err}
        kmc_tools transform data/kmc_temp/{params.kmer_length}mers_{wildcards.genome_name} \
            dump results/feature_engineering/kmer_counts/{params.kmer_length}mers/{wildcards.genome_name}_{params.kmer_length}mers.txt \
            1> {log.out} 2> {log.err}
        """
        
# Concatenates all the kmer count files generated above
rule concat_kmer_counts:
    input:
        input_kmer_count_files=expand(
            "results/feature_engineering/kmer_counts/{nucl_kmer_length}mers/{genome_name}_{nucl_kmer_length}mers.txt", 
            genome_name=genome_names,
            nucl_kmer_length=config["parameters"]["nucl_kmer_length"]
        ),
        kmer_concat_script="workflow/scripts/feature_engineering/concat_kmer_counts.py"
    output:
        "results/all_{nucl_kmer_length}mer_counts.csv"
    log:
        err="logs/concat_kmer_counts/{nucl_kmer_length}mers/{nucl_kmer_length}.err",
        out="logs/concat_kmer_counts/{nucl_kmer_length}mers/{nucl_kmer_length}.out",
    params:
        kmer_length=config["parameters"]["nucl_kmer_length"]
    conda:
        "../envs/data_prep.yml"
    script:
        "../scripts/feature_engineering/concat_kmer_counts.py"

# Creates fake features for the dataset
rule create_fake_phenotype_data:
    input:
        all_kmer_counts="data/all_kmer_counts.csv",
    params:
        target_column=config['phenotype']['target_column'],
    output:
        merged_data="data/merged_data.csv"
    log:
        err="logs/combine_data_sets.err",
        out="logs/combine_data_sets.out"
    conda:
        "../envs/data_prep.yml"
    script:
        "../scripts/feature_engineering/combine_datasets.py"
