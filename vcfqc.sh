#!/bin/bash

# requirements: bcftools, python3 w/ pandas

if [[ $(type -P "bcftools" | wc -l) == 0 ]]; then
	echo PLEASE ADD SAMTOOLS TO PATH 
	return
	exit 1
fi
BCFTOOLS=$(which bcftools)  # should be given by conda 

if [[ $(type -P "python3" | wc -l) == 0 ]]; then
	echo PLEASE ADD PYTHON3 W/ PANDAS TO PATH 
	return
	exit 1
fi

vcf_1=$1
vcf_2=$2
collect_tsv=$3

# check if vars legit & vcfs are bg zipped & index

echo logging results at: $collect_tsv

# get name tag of comparison
comp_name=$(basename $vcf_1 | cut -b 1-3)_$(basename $vcf_2 | cut -b 1-3)

# collect vars for header & values
output_header="" 
output_values=$comp_name


# produce files to parse data from
$BCFTOOLS stats $vcf_1 > stats_1.tmp
$BCFTOOLS stats $vcf_2 > stats_2.tmp
$BCFTOOLS merge $vcf_1 $vcf_2 --force-samples --info-rules 'DP:join,MQ:join,QD:join' -o merge.vcf  # gt mismatches


# get total number of vars
vars_1=$(grep "number of records:" stats_1.tmp | cut -d $'\t' -f 4)
vars_2=$(grep "number of records:" stats_2.tmp | cut -d $'\t' -f 4)
diff_vars=$(echo "($vars_1-$vars_2)"| bc -l | sed 's/-//')
# collect
output_header="$output_header	vars_diff"
output_values="$output_values	$diff_vars"


# get number of snps & indels via bcf tools view to calc differences 
indel_count_1=$($BCFTOOLS view $vcf_1 --types indels | grep "^[^#;]" | wc -l)  # snps indels for vcf1
snp_count_1=$($BCFTOOLS view $vcf_1 --types snps | grep "^[^#;]" | wc -l)

indel_count_2=$($BCFTOOLS view $vcf_2 --types indels | grep "^[^#;]" | wc -l) # snps indels for vcf2
snp_count_2=$($BCFTOOLS view $vcf_2 --types snps  | grep "^[^#;]" | wc -l)

snp_diff=$(expr ${snp_count_1} - ${snp_count_2} | sed 's/-//')  # differences in snp & indel counts
indel_diff=$(expr ${indel_count_1} - ${indel_count_2} | sed 's/-//')
# collect
output_header="$output_header	snps_diff	indels_diff"
output_values="$output_values	$snp_diff	$indel_diff"

# get genotype mismatches
python3 ./getGenotypeStats.py merge.vcf gt_mismatches.tmp
gt_outp="$(cat gt_mismatches.tmp)" && rm gt_mismatches.tmp
# collect
output_header="$output_header	gt_mismatches"
output_values="$output_values	$gt_outp"


# get Ti/Tv ratio
ti_tvs_1="$(grep "^TSTV" stats_1.tmp | cut -f 5)"
ti_tvs_2="$(grep "^TSTV" stats_2.tmp | cut -f 5)"
diff_titv=$(echo "($ti_tvs_1-$ti_tvs_2)"| bc -l | sed 's/-//')
# collect
output_header="$output_header	Ti/Tv_diff"
output_values="$output_values	$diff_titv"


# get metric differences of merge vars via python
##########
python3 ./getMetricDifferenceStats.py merge.vcf vcf_log.tmp

fields=($(cut --complement -d$'\t' -f 1 vcf_log.tmp | head -n 1))
means=($(cut --complement -d$'\t' -f 1 vcf_log.tmp | head -n 2 | tail -n 1))
stds=($(cut --complement -d$'\t' -f 1 vcf_log.tmp | head -n 3 | tail -n 1))

# put array vals into output cols
for i in $(seq 0 $(expr ${#fields[@]} - 1));do 
	output_header="$output_header	${fields[$i]}_mean	${fields[$i]}_std"
	output_values="$output_values	${means[$i]}	${stds[$i]}"
done

# remove temp files
rm vcf_log.tmp merge.vcf stats_1.tmp stats_2.tmp

# build chromosomes for var per chr count
chromosomes="$(zcat  $vcf_1 | grep -v "^#" | cut -d $'\t' -f 1 | uniq | less)"
vcf1_chr_counts=""
vcf2_chr_counts=""

# get var counts pro chromosome
for chr in $chromosomes; do
	vcf1_chr_counts="$vcf1_chr_counts $(zcat $vcf_1 | grep -v "^#" | grep $chr | wc -l)"
	vcf2_chr_counts="$vcf2_chr_counts $(zcat $vcf_2 | grep -v "^#" | grep $chr | wc -l)"
done

# convert to array for easy access
chromosomes=($chromosomes)
vcf1_chr_counts=($vcf1_chr_counts)
vcf2_chr_counts=($vcf2_chr_counts)

# collect header & values
for i in $(seq 0 $(expr ${#vcf1_chr_counts[@]} - 1)); do 
	output_header="$output_header	${chromosomes[i]}_diff"
	output_values="$output_values	$(expr ${vcf1_chr_counts[$i]} - ${vcf2_chr_counts[$i]} | sed 's/-//')"
done

# if parsed table exists, only append values to it
# if it does not exist -> new file w/ header
if [[ ! -f $collect_tsv ]]; then
	echo -e "$output_header" > $collect_tsv
	echo -e "$output_values" >> $collect_tsv
else
	echo -e "$output_values" >> $collect_tsv
fi
