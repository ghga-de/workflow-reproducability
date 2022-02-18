import pandas as pd
import sys

path = sys.argv[1]
outpath = sys.argv[2]

req_fields = ["DP", "MQ", "QD"]

vcf = pd.read_csv(path, sep="\t", comment="#", header=None)
vcf.columns = ["#CHROM", "POS", "ID", "REF", "ALT", "QUAL", "FILTER", "INFO", "FORMAT", "Sample1", "Sample2"]

# extract relevant info fields together, inside vcf info col: ...DP=3,3;MQ=24.04,24.04;QD=24.28,24.28...
collect = vcf["INFO"].apply(lambda x: {entry.split("=")[0]:entry.split("=")[1] for entry in x.split(";") if entry.split("=")[0] in req_fields})
new_collect = [x for x in collect]  # to avoid weird pointer issues

# make new df for easy computation
calc_df = pd.DataFrame(new_collect) 
'''
example calc_df:
        DP           MQ           QD
        3,3  24.01,24.01  13.88,13.88
        3,3  24.04,24.04  24.28,24.28
'''

# get difference of values
mean_stds = {}  # "QD" : [mean, std]
for field in req_fields:
    differences = calc_df[field].apply(lambda x: abs(float(x.split(",")[0]) - float(x.split(",")[1])))
    mean_stds[field] = [differences.mean(), differences.std()]
    
output_df = pd.DataFrame(mean_stds)  # cols: metrics, rows: mean, std_dev
output_df.index = ["mean", "std_dev"]
output_df = output_df.round(decimals=2)

output_df.to_csv(outpath, sep="\t")
