#!/bin/bash

inFile=$1
outDir=$2
tmp=`mktemp -t`
#echo ${inFile/.vcf.gz/} > $tmp
out1=${inFile##*/}
out2=${out1%%.*}
echo $out2 > $tmp
zcat $inFile | cut -f1-10 | bcftools reheader -s $tmp -o $outDir$out2.out
echo "$inFile tumor sample renamed, germline sample removed."
