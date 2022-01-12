#!/bin/bash

# requirements: samtools 
SAMTOOLS=`which samtools`

READLEN=101
bam_1=$1
bam_2=$2
collect_tsv=$3
readlen=101  # used for depth calculation

echo logging results at: $3

comp_name=$(basename $bam_1 | cut -b 1-3)_$(basename $bam_2 | cut -b 1-3)
output_header=""
output_values="$comp_name"


$SAMTOOLS flagstat $bam_1 > bam1_stats.tmp
$SAMTOOLS flagstat $bam_2 > bam2_stats.tmp

qcpassed_1=`grep QC-passed bam1_stats.tmp | cut -d "+" -f 1`
qcpassed_2=`grep QC-passed bam2_stats.tmp | cut -d "+" -f 1`
output_header="$output_header	qc_passed_diff"
output_values="$output_values	$(expr $qcpassed_1 - $qcpassed_2 | sed 's/-//')"

# # of mapped reads
mapped_1=`grep "mapped (" bam1_stats.tmp | cut -d "+" -f 1`
mapped_2=`grep "mapped (" bam2_stats.tmp | cut -d "+" -f 1`
output_header="$output_header	mapped_reads_diff"
output_values="$output_values	$(expr $mapped_1 - $mapped_2 | sed 's/-//')"

# reads paired in sequecing
paired_1=`grep "paired in sequencing" bam1_stats.tmp | cut -d "+" -f 1`
paired_2=`grep "paired in sequencing" bam2_stats.tmp | cut -d "+" -f 1`
output_header="$output_header	paired_reads_diff"
output_values="$output_values	$(expr $paired_1 - $paired_2 | sed 's/-//')"

# get depth stats
# important: this abstracts only depth, softclipped bases are not considered
$SAMTOOLS idxstats $bam_1 | head -n 24 > bam1_idxstats.tmp  # head -n 24 to only keep chr 1-Y
$SAMTOOLS idxstats $bam_2 | head -n 24 > bam2_idxstats.tmp  

chrs=($(cat bam1_idxstats.tmp | cut -f 1))
chr_lens=($(cat bam1_idxstats.tmp | cut -f 2))
ali_reads_1=($(cat bam1_idxstats.tmp | cut -f 3))
ali_reads_2=($(cat bam2_idxstats.tmp | cut -f 3))
calc() { awk "BEGIN{print $*}"; }
depths_1=""
depths_2=""

for i in $(seq 0 $(expr ${#chrs[@]} - 1));do 
	# get depth values for each bam
    dp1=$(calc ${ali_reads_1[$i]} "*" $readlen / ${chr_lens[$i]})
    dp2=$(calc ${ali_reads_2[$i]} "*" $readlen / ${chr_lens[$i]})

	# calc abs difference & abbend to output
    diff_dp=$(calc $dp1 - $dp2 | sed 's/-//')
    output_header="$output_header	chr${chrs[$i]}_dp_diff"
	output_values="$output_values	$diff_dp"
done

# if parsed table exists, only append values to it
# if it does not exist -> new file w/ header

if [[ ! -f $collect_tsv ]]; then
	echo -e "$output_header" > $collect_tsv
	echo -e "$output_values" >> $collect_tsv
else
	echo -e "$output_values" >> $collect_tsv
fi
