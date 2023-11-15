#!/usr/bin/env Rscript
# ---------------------------
# kmer distribution plots for amino acid kmers
# Author: Paul Villanueva (github.com/pommevilla)
# ---------------------------
############ Setup ############
library(tidyverse)

theme_set(
    theme_light() +
        theme(
            panel.grid.minor = element_blank()
        )
)

nice_expansion <- expansion(add = 0, mult = c(0, 0.1))

#### Helper functions ####
prep_aa_kmer_count_df <- function(aa_file_path) {
    read_delim(aa_file_path, delim = "\t", show_col_types = FALSE) %>%
        group_by(kmer) %>%
        summarise(across(everything(), sum)) %>%
        pivot_longer(-kmer) %>%
        pivot_wider(names_from = kmer, values_from = value) %>%
        mutate(genome = sub("_.*", "", name), .before = everything(), .keep = "unused")
}

plot_kmer_count_histogram <- function(kmer_df, saveout = FALSE, logged = FALSE) {
    kmer_length <- nchar(colnames(kmer_df)[2])
    kmer_df <- kmer_counts_by_genome %>%
        summarise(across(-genome, sum)) %>%
        pivot_longer(everything(), names_to = "kmer", values_to = "count")

    count_summaries <- kmer_df %>%
        summarise(
            Mean = mean(count),
            median = median(count)
        ) %>%
        pivot_longer(everything(), names_to = "statistic", values_to = "count")

    this_x_title <- paste0("Number of times ", kmer_length, "-mer occurs in genome")
    if (logged) {
        this_x_title <- paste0(this_x_title, " (log10)")
    }

    this_plot_title <- paste0(
        "Distribution of ", kmer_length, "-mer counts across first 99 assembled genomes"
    )

    # Get column sums of all 10-mers
    p <- kmer_df %>%
        ggplot(aes(count)) +
        geom_histogram(bins = 100) +
        scale_y_continuous(expand = nice_expansion) +
        labs(
            x = this_x_title,
            y = "Count",
            title = this_plot_title,
        ) +
        theme(
            plot.title = element_text(hjust = 0.5),
            legend.position = c(0.9, 0.9),
            legend.box.background = element_rect(color = "black", size = 1),
            panel.grid.major.x = element_blank()
        ) +
        geom_vline(
            data = count_summaries,
            aes(xintercept = count, color = statistic)
        ) +
        guides(
            color = guide_legend(title = NULL)
        )

    if (logged) {
        p <- p + scale_x_log10()
    }

    if (saveout) {
        if (logged) {
            this_plot_path <- paste0("results/plots/aa_kmer_counts/", kmer_length, "_mers_counts_logged.png")
        } else {
            this_plot_path <- paste0("results/plots/aa_kmer_counts/", kmer_length, "_mers_counts.png")
        }
        ggsave(
            this_plot_path,
            plot = p,
            width = 10, height = 8
        )
        paste0("Logged: ", logged, " saved to ", this_plot_path)
    }

    return(p)
}


plot_kmer_count_pa_histogram <- function(kmer_df, saveout = FALSE) {
    kmer_length <- nchar(colnames(kmer_df)[2])
    kmer_df <- kmer_df %>%
        mutate(across(-genome, ~ ifelse(. > 0, 1, 0))) %>%
        summarise(across(-genome, sum)) %>%
        pivot_longer(everything(), names_to = "kmer", values_to = "count")

    pa_summaries <- kmer_df %>%
        summarise(
            Mean = mean(count),
            median = median(count)
        ) %>%
        pivot_longer(everything(), names_to = "statistic", values_to = "count")

    this_x_title <- paste0(kmer_length, "-mer")


    this_plot_title <- paste0(
        "Presence/absence of ", kmer_length, "-mers across first 99 assembled genomes"
    )

    p <- kmer_df %>%
        ggplot(aes(kmer, count)) +
        geom_point(alpha = 0.5, size = 3) +
        scale_y_continuous(expand = nice_expansion, limits = c(0, 99)) +
        labs(
            x = this_x_title,
            y = "Count",
            title = this_plot_title,
        ) +
        theme(
            plot.title = element_text(hjust = 0.5),
            legend.box.background = element_rect(color = "black", size = 1),
            panel.grid.major.x = element_blank(),
            axis.text.x = element_blank(),
            axis.ticks.x = element_blank(),
        ) +
        geom_hline(
            data = pa_summaries,
            aes(yintercept = count, color = statistic),
            size = 2
        ) +
        guides(
            color = guide_legend(title = NULL)
        )

    if (saveout) {
        this_plot_path <- paste0("results/plots/aa_kmer_pa/", kmer_length, "_mers_pa.png")
        ggsave(
            this_plot_path,
            plot = p,
            width = 10, height = 8
        )
    }

    return(p)
}
# Generates all kmer count histograms in both logged and unlogged versions
kmer_lengths <- c(3, 4, 5, 10, 11)
aa_count_path <- "results/feature_engineering/kmers/aa/{kmer_length}mers/combined_prod.tsv"

# for (kmer_length in kmer_lengths) {
#     kmer_counts_by_genome <- prep_aa_kmer_count_df(glue::glue(aa_count_path))
# }



############ kmer count variance filtering ############
# Loops through the kmer files to get # kmers before and after
# filtering for zero variance and variance > 10 (arbitrary cutoff)
variance_df <- data.frame(
    kmer = numeric(),
    total_obs = numeric(),
    after_zv = numeric(),
    mean_variance = numeric()
)

for (kmer_length in kmer_lengths) {
    kmer_counts_by_genome <- prep_aa_kmer_count_df(glue::glue(aa_count_path))

    k <- nchar(colnames(kmer_counts_by_genome)[2])
    total_obs <- dim(kmer_counts_by_genome)[2] - 1
    print(paste0("####### k=", k))

    # Count histograms
    plot_kmer_count_histogram(kmer_counts_by_genome, saveout = TRUE)
    plot_kmer_count_histogram(kmer_counts_by_genome, logged = TRUE, saveout = TRUE)

    # Presence/absence plots
    plot_kmer_count_pa_histogram(kmer_counts_by_genome, saveout = TRUE)



    cat(paste0("\tDims before: ", total_obs, "\n"))

    variances <- apply(kmer_counts_by_genome %>% select(-genome), 2, var) %>%
        as.data.frame() %>%
        rename(variance = 1) %>%
        rownames_to_column("kmer")

    zv_length <- variances %>%
        filter(variance > 0) %>%
        count()

    cat(paste0("\tDims after zv filter: ", zv_length, "\n"))

    # Add row to variance df with kmer, total_obs, after_zv, mean_variance
    variance_df <- variance_df %>%
        add_row(
            kmer = k,
            total_obs = total_obs,
            after_zv = zv_length %>% pull(n),
            mean_variance = mean(variances$variance)
        )
}

write_csv(
    variance_df,
    "results/feature_engineering/kmers/aa/variance_filtering.csv"
)
