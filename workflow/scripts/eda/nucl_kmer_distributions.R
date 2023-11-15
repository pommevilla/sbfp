#!/usr/bin/env Rscript
# ---------------------------
# kmer distribution plots
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

kmer_counts_by_genome <- read.csv("results/all_13mer_counts.csv") %>%
    mutate(genome = sub("_.*", "", genome), .before = everything())

# List of all the kmer count files
kmer_count_files <- list.files("results/", pattern = "mer_counts.csv", full.names = TRUE)


############ kmercount histograms ############
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
            this_plot_path <- paste0("results/plots/kmer_counts/", kmer_length, "_mers_logged.png")
        } else {
            this_plot_path <- paste0("results/plots/kmer_counts/", kmer_length, "_mers.png")
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

# Generates all kmer count histograms in both logged and unlogged versions
for (kmer_count_file in kmer_count_files) {
    kmer_counts_by_genome <- read.csv(kmer_count_file) %>%
        mutate(genome = sub("_.*", "", genome), .before = everything())

    plot_kmer_count_histogram(kmer_counts_by_genome, saveout = TRUE)
    plot_kmer_count_histogram(kmer_counts_by_genome, logged = TRUE, saveout = TRUE)
}

plot_kmer_count_histogram(kmer_counts_by_genome)


############ kmer count variance filtering ############
# Loops through the kmer files to get # kmers before and after
# filtering for zero variance and variance > 10 (arbitrary cutoff)
for (kmer_count_file in kmer_count_files) {
    kmer_counts_by_genome <- read.csv(kmer_count_file) %>%
        mutate(genome = sub("_.*", "", genome), .before = everything())

    k <- nchar(colnames(kmer_counts_by_genome)[2])
    print(paste0("####### k=", k))
    cat(paste0("\tDims before: ", dim(kmer_counts_by_genome)[2] - 1, "\n"))

    variances <- apply(kmer_counts_by_genome %>% select(-genome), 2, var) %>%
        as.data.frame() %>%
        rename(variance = 1) %>%
        rownames_to_column("kmer")

    zv_length <- variances %>%
        filter(variance > 0) %>%
        count()

    cat(paste0("\tDims after zv filter: ", zv_length, "\n"))

    var_10_length <- variances %>%
        filter(variance > 10) %>%
        count()

    cat(paste0("\tDims after var 10 filter: ", var_10_length, "\n"))
}

############ kmer presence absence ############
pa_kmer_df <- kmer_counts_by_genome %>%
    mutate(across(-genome, ~ ifelse(. > 0, 1, 0)))

pa_counts <- pa_kmer_df %>%
    summarise(across(-genome, sum)) %>%
    pivot_longer(everything(), names_to = "kmer", values_to = "count")

pa_summary <- pa_counts %>%
    summarise(
        Mean = mean(count),
        median = median(count)
    ) %>%
    pivot_longer(everything(), names_to = "statistic", values_to = "count")


pa_counts %>%
    ggplot(aes(kmer, count)) +
    geom_point() +
    theme(
        panel.grid.major.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
    ) +
    labs(
        x = "kmer",
        y = "# genomes observed",
        title = "Something"
    ) +
    scale_y_continuous(expand = nice_expansion, limits = c(0, 99)) +
    geom_hline(
        data = pa_summary,
        aes(yintercept = count, color = statistic)
    )

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
        this_plot_path <- paste0("results/plots/kmer_counts/pa_plots/", kmer_length, "_mers.png")
        ggsave(
            this_plot_path,
            plot = p,
            width = 10, height = 8
        )
    }

    return(p)
}

plot_kmer_count_pa_histogram(kmer_counts_by_genome)

# Generates and saves kmer p/a plots
for (kmer_count_file in kmer_count_files) {
    kmer_counts_by_genome <- read.csv(kmer_count_file) %>%
        mutate(genome = sub("_.*", "", genome), .before = everything())

    plot_kmer_count_pa_histogram(kmer_counts_by_genome, saveout = TRUE)
}


kmer_counts_by_genome
