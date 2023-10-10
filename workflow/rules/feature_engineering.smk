# ---------------------------
# Rules about feature extraction/engineering
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

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
