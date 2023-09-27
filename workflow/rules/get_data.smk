# ---------------------------
# Rules to get data from SRA
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

rule prefetch_sras:
    input:
        sras_list = "data/sras.txt",
        sra_fetch_script = "workflow/scripts/download_sras.sh"
    output:
        touch(".sras_fetched")
    log:
        err = "logs/prefetch_sra_data.err",
        out = "logs/prefetch_sra_data.out"
    shell:
        """
        {input.sra_fetch_script} -i {input.sras_list} 2> {log.err} 1> {log.out}
        """

rule dump_fastqs:
    input:
        ".sras_fetched",
        sras_list = "data/sras.txt",
        sra_dump_script = "workflow/scripts/dump_fastqs.sh",
    output:
        touch(".fastqs_dumped")
    log:
        err = "logs/dump_fastqs.err",
        out = "logs/dump_fastqs.out"
    shell:
        """
        {input.sra_dump_script} -i {input.sras_list} 2> {log.err} 1> {log.out}
        """