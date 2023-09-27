# ---------------------------
# Rules about modeling
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------

rule train_xgboost:
    input:
        "data/all_kmer_counts.csv",
        modeling_script = "workflow/scripts/modeling/train_xgboost.py"
    output:
        "results/modeling/xgboost_gridsearch.pkl"
    log:
        err = "logs/train_xgboost.err",
        out = "logs/train_xgboost.out"
    conda:
        "modeling"
    shell:
        """
        {input.modeling_script} 2> {log.err} 1> {log.out}
        """