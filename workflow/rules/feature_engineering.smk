# ---------------------------
# Rules about feature extraction/engineering
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

# Generates kmer count files for individual genomes
rule count_kmers:
    output:
        "results/feature_engineering/kmer_counts/{genome_name}_5mers.txt"
    input:
    params:
        genome_directory=config["data_prep"]["genome_directory"],
    log:
        err="logs/count_kmers_{genome_name}.err",
        out="logs/count_kmers_{genome_name}.out"
    shell:
        """
        echo -e '\tInput {params.genome_directory}/{wildcards.genome_name}'
        echo -e '\tOutput data/kmc_temp/15mers_{wildcards.genome_name}'
        kmc -k5 -fm {params.genome_directory}/{wildcards.genome_name} data/kmc_temp/15mers_{wildcards.genome_name} data/kmc_temp
        kmc_tools transform data/kmc_temp/15mers_{wildcards.genome_name} dump results/feature_engineering/kmer_counts/{wildcards.genome_name}_5mers.txt
        """
        
# Concatenates all the kmer count files generated above
rule concat_kmer_counts:
    input:
        input_kmer_count_files=expand("results/feature_engineering/kmer_counts/{genome_name}_5mers.txt", genome_name=genome_names),
        kmer_concat_script="workflow/scripts/feature_engineering/concat_kmer_counts.py"
    output:
        "data/all_kmer_counts.csv"
    log:
        err="logs/concat_kmer_counts.err",
        out="logs/concat_kmer_counts.out"
    params:
        test="Please work"
    conda:
        "../envs/data_prep.yml"
    script:
        "../scripts/feature_engineering/concat_kmer_counts.py"

# Combines kmer count information with phenotypic data
rule combine_data_sets:
    input:
        all_kmer_counts="data/all_kmer_counts.csv",
        phenotypic_data=config['phenotype']['phenotype_file']
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
