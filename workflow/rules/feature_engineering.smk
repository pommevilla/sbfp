# ---------------------------
# Rules about feature extraction/engineering
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

rule count_kmers:
    input:
        ".fastqs_dumped",
        sras_list = "data/sras.txt",
        kmer_count_script = "workflow/scripts/feature_engineering/get_kmer_counts.sh"
    output:
        touch(".kmers_counted")
    log:
        err = "logs/count_kmers.err",
        out = "logs/count_kmers.out"
    shell:
        """
        {input.kmer_count_script} -i {input.sras_list} 2> {log.err} 1> {log.out}
        """
        
rule concat_kmer_counts:
    input:
        ".kmers_counted",
        kmer_concat_script = "workflow/scripts/feature_engineering/concat_kmer_counts.py"
    output:
        "data/all_kmer_counts.csv"
    log:
        err = "logs/concat_kmer_counts.err",
        out = "logs/concat_kmer_counts.out"
    conda:
        "data_prep"
    shell:
        """
        {input.kmer_concat_script} 2> {log.err} 1> {log.out}
        """