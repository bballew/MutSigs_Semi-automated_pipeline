#!/bin/bash

inFile=$1

printf "Total variants across all input files:\t"
grep -c "^.*$" $inFile
printf "Total variants in canonical chromosomes across all input files:\t"
grep -cv "vcf.gz:GL" $inFile
printf "Total non-SNVs (insertions, deletions, indels):\t"
cut -f4-5 $inFile | grep -cE "[ACGT]{2,}"
printf "Multi-allelic loci:\t"
cut -f4-5 $inFile | grep -cv "[ACGT]"
