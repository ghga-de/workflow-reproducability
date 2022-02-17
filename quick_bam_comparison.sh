#!/bin/bash

BAM1=$1
BAM2=$2
MEM=$3
PICARDOUTP_PATH=$4

# check md5sums
if [[ $(md5sum "$BAM1" | cut -f 1 -d " ") == $(md5sum "$BAM2" | cut -f 1 -d " ") ]]; then
    echo FILES ARE EQUAL
else  # if unequal, run picard comparesams
    echo FILES ARE NOT EQUAL, RUNNING PICARD COMPARE BAMS
    echo
    # check picard in PATH
    if [[ $(type -P "picard" | wc -l) == 0 ]]; then
        echo PLEASE ADD PICARD TO PATH VARIABLE
        return
        exit 1
    fi
    
    echo picard -Xmx"${MEM}" CompareSAMs "$BAM1" "$BAM2" -O "$PICARDOUTP_PATH"
fi
