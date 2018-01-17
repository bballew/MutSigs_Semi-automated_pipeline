#!/bin/bash

inFile=$1

cat <(sed '/^#CHROM/q' $inFile) <(awk '{FS=OFS="\t"} ($0 !~ /^#/ && $3 ~ /\./){print $0}' $inFile | grep -v "ESP_ALL_MAF\|ExAC_ALL_MAF\|1KG_AF")