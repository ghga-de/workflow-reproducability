# GHGA QC tools

## Overview
The two main scripts can be used to compare two BAM (`bamqc.sh`) or two VCF (`vcfqc.sh`) files on different metrics.
Results of each comparison are collected in a table that has to be specified in the input parameters (`collect_table.tsv`).


Requirements are: 
* Samtools >= 1.6
* Bcftools >= 1.6
* python >= 3
* pandas >= 1.0.0

In addition theres is also a quick wrapper script for comparing two bamfiles (`quick_bam_comparison.sh`). It first checks md5sums of both files, if they are unequal it runs the picard CompareSAMs tool with stringent settings. These results will not not be collected in a central table. The script will only produce the picard results table.


Requirements are: 
* picard >= 2.19.1

## Run tools
```bash
bamqc.sh bamfile1 bamfile2 collect_bam_table.tsv
```

```bash
vcfqc.sh vcffile1 vcffile2 collect_vcf_table.tsv
```
note: vcf inputs for `vcfqc.sh` have to be bgzipped & indexed


also note: you can concatenate multiple comparisons for each bamqc & vcfqc into a single `collect_table.tsv`. 

```bash
quick_bam_comparison.sh bamfile1 bamfile2 picard_memory picard_output_file
```
note: picard_memory has to be in java conform format (see https://docs.oracle.com/javase/7/docs/technotes/tools/solaris/java.html)

## Comparison metrics of bamqc.sh and vcfqc.sh
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
* Difference of variant per chromosome (`chr1_diff`, `chr2_diff`  ... `chrY_diff`)

