#!/bin/bash
# ---------------------------
# Rules to get data from SRA
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

rule get_data:
    input:
        sras_to_download = "data/sras.text",
        sra_fetch_script = "scripts/sra_fetch.sh"
    output:
        touch(".sras_fetched")
    log:
        err = "logs/prefetch_sra_data.err",
        out = "logs/prefetch_sra_data.out"
    shell:
        """
        {input.sra_fetch_script} -i {input.sras_to_download} 2> {log.err} 1> {log.out}
        """