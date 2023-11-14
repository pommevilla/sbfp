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
        err="logs/count_nucl_kmers/{nucl_kmer_length}/{genome_name}/count_kmers_{genome_name}.err",
        out="logs/count_nucl_kmers/{nucl_kmer_length}/{genome_name}/count_kmers_{genome_name}.out"
    conda:
        "../envs/kmc.yml"
    resources:
        mem_mb=12000
    shell:
        """
        mkdir data/kmc_temp/{wildcards.genome_name}_{params.kmer_length}
        kmc -k{params.kmer_length} -v -fm {params.genome_directory}/{wildcards.genome_name} \
            data/kmc_temp/{params.kmer_length}mers_{wildcards.genome_name} \
            data/kmc_temp/{wildcards.genome_name}_{params.kmer_length} 1> {log.out} 2> {log.err}
        kmc_tools transform data/kmc_temp/{params.kmer_length}mers_{wildcards.genome_name} \
            dump results/feature_engineering/kmer_counts/{params.kmer_length}mers/{wildcards.genome_name}_{params.kmer_length}mers.txt \
            1> {log.out} 2> {log.err}
        """
        
# Concatenates all the kmer count files generated above
rule concat_nucl_kmer_counts:
    input:
        input_kmer_count_files=expand(
            "results/feature_engineering/kmers/aa/{nucl_kmer_length}mers/{genome_name}_{nucl_kmer_length}mers.txt", 
            genome_name=GENOME_NAMES,
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

# Find orfs for AA counting
rule find_orfs:
    output:
        "working/orfs/{genome_name}/{genome_name}.faa"
    log:
        err="logs/find_orfs/{genome_name}/find_orfs.err",
        out="logs/find_orfs/{genome_name}/find_orfs.out"
    conda:
        "../envs/orfipy.yml"
    params:
        outdir=lambda wildcards, output: os.path.dirname(output[0]),
        outfile=lambda wildcards, output: os.path.basename(output[0]),
        genome_directory=config["directories"]["genome_directory"]
    shell:
        """
        orfipy {params.genome_directory}/{wildcards.genome_name} \
            --outdir {params.outdir} \
            --pep {params.outfile} \
            1> {log.out} 2> {log.err}
        """

rule count_aa_kmers:
    output:
        "results/feature_engineering/kmers/aa/{aa_kmer_length}mers/combined_prod.tsv"
    params:
        genome_directory=config["directories"]["genome_directory"],
        output_dir=lambda wildcards, output: os.path.dirname(output[0]),
        min_count=determine_mercat_min_count
    log:
        err="logs/count_aa_kmers/{aa_kmer_length}/count_aa_{aa_kmer_length}mers.err",
        out="logs/count_aa_kmers/{aa_kmer_length}/count_aa_{aa_kmer_length}mers.out"
    conda:
        "../envs/mercat2.yml"
    threads: determine_mercat_threads
    resources:
        mem_mb=48000
    shell:
        """
        mercat2.py -f {params.genome_directory} \
            -k {wildcards.aa_kmer_length} \
            -n {threads} \
            -c {params.min_count} \
            -prod \
            -skipclean \
            -o {params.output_dir} \
            1> {log.err} 2> {log.out}
        """ 

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
