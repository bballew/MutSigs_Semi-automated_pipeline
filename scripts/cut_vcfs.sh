#!/bin/bash

inFile=$1
# firstCol=$2
# secondCol=$3
outPath=$2

n1=${inFile%%.*}
n2=${n1##*/}".out"

if (zgrep -vHm1 "^#" $inFile | cut -f10 | grep -q "^0/1:")
then
  echo "$inFile has tumor data in the first genotype column."
  zcat $inFile | cut --complement -f11 > $outPath$n2
elif (zgrep -vHm1 "^#" $inFile | cut -f11 | grep -q "^0/1:")
then
  echo "$inFile has tumor data in the second genotype column."
  zcat $inFile | cut --complement -f10 > $outPath$n2
else
  echo "ERROR: Did not detect tumor data in either genotype column for $inFile."
  exit 1
fi

# echo "Processing files with tumor data in first genotype column:"
# while read f
# do
#   echo "Processing $f file..."
#   n1=${f%%.*}
#   n2=${n1##*/}".out"
#   zcat $f | cut --complement -f11 > $outPath$n2
# done <$firstCol

# echo "Processing files with tumor data in second genotype column:"
# while read i
# do
#   echo "Processing $i file..."
#   m1=${i%%.*}
#   m2=${m1##*/}".out"
#   zcat $i | cut --complement -f10 > $outPath$m2
# done <$secondCol
