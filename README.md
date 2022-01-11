# GHGA QC tools

## Overview
These two scripts can be used to compare two BAM (`bamqc.sh`) or two VCF (`vcfqc.sh`) files on different metrics.
Results of each comparison are collected in a table that has to be specified in the input parameters (`collect_table.tsv`).


Requirements are: 
* Samtools >= 1.6
* Bcftools >= 1.6
* python >= 3
* pandas >= 1.0.0

## Run tools
```bash
bamqc.sh bamfile1 bamfile2 collect_table.tsv
```

```bash
vcfqc.sh bamfile1 bamfile2 collect_table.tsv
```
## Comparison metrics
BAM comparison metrics:
* Difference of QC-passed reads (`qc_passed_diff`)
* Difference of mapped reads (`mapped_reads_diff`)
* Difference of paired reads (`paired_reads_diff`)
* Difference of average depth per chromosome (`chr1_dp_diff`, `chr2_dp_diff` ... `chrY_dp_diff`)


VCF comparison metrics:
* Difference of variant counts (`vars_diff`)
* Difference of SNP counts (`snps_diff`)
* Differences of indel counts (`indels_diff`)
* Number of genotype mismatches (`gt_mismatches`)
* Difference of transition/transversion ratios (`Ti/Tv_diff`)
* Mean and standard deviation of DP, MQ and QD differences (`DP_mean`, `DP_std`, `MQ_mean` ... `QD_std`)	
* Difference of variant per chromosome (`chr1_diff` ... `chrY_diff`)

