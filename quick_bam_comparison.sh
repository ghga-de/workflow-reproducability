#!/bin/bash

BAM1=$1
BAM2=$2
MEM=$3
PICARDOUTP_TSV=$4

# check md5sums of bamfiles, w/o header
if [[ $(samtools view "$BAM1" | md5sum | cut -f 1 -d " ") == $(samtools view "$BAM2" | md5sum | cut -f 1 -d " ") ]]; then
    echo FILES ARE EQUAL
else  # if unequal, run picard comparesams
    echo FILES ARE NOT EQUAL, RUNNING PICARD COMPARE SAMS
    echo
    
    echo picard -Xmx"${MEM}" CompareSAMs "$BAM1" "$BAM2" -O "$PICARDOUTP_TSV"
fi
