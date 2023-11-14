# ---------------------------
# Rules about feature extraction/engineering
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

localrules: prepare_db_fasta, makeblastdb

rule prepare_db_fasta:
    input:
        genome_files
    output:
        "working/all.fasta"
    log:
        out="logs/prepare_db_fasta/prepare_db_fasta.out",
        err="logs/prepare_db_fasta/prepare_db_fasta.err"
    params:
        genome_directory=config['directories']['genome_directory'],
    shell:
        """
        for fin in {params.genome_directory}/*fasta; do
            echo "$fin"
            sed "s|^>|>${{fin##.*/}}:|g" "$fin" >> {output}
        done 1> {log.out} 2> {log.err}
        """

rule makeblastdb:
    input:
        "outputs/all.fasta"
    output:
        expand("outputs/db/sbfpDB.{ext}", ext=BLAST_DB_SUFFIXES)
    log:
        out="logs/makeblastdb/makeblastdb.out",
        err="logs/makeblastdb/makeblastdb.err"
    conda:
        "../envs/blast.yml"
    shell:
        """
        makeblastdb -in {input} -dbtype nucl -out outputs/db/sbfpDB  1> {log.out} 2> {log.err}
        """
