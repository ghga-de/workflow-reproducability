import pandas as pd
import sys, os

path = "/projects/ccg-ngs/tmp/leon/ghga_qc/dev_merge.vcf"

path = sys.argv[1]
outpath = sys.argv[2]

req_fields = ["/", "|"]

vcf = pd.read_csv(path, sep="\t", comment="#", header=None)
vcf.columns = ["#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", "Sample1", "Sample2"]

gt_index = vcf["FORMAT"].iloc[0].split(":").index("GT")  # get index of genotype from format

sample1_gts = vcf["Sample1"].apply(lambda x: x.split(":")[gt_index])  # extract GTs from dataframe
sample2_gts = vcf["Sample2"].apply(lambda x: x.split(":")[gt_index])

gt_mismatches = [1 for x,y in zip(sample1_gts, sample2_gts) if x != y]

with open(outpath,"w") as outfile:
    outfile.write(str(sum(gt_mismatches)))
    outfile.close()
