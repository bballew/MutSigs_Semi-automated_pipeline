#!/bin/bash

# It take a really long time to load a large VCF into R and generate a motif matrix.
# This automates splitting a VCF file up, loading into R, and generating multiple
# matrices, which are then added together in R.  The motif matrix has 96 x # samples
# dimensions (or up to ~200 x # samples  if you are also looking at indels or strand 
# bias), so this is a much smaller representation of the data compared to the original
# VCF.

# Input reqs:
	# Standard format VCF file
	# Scripts (in addition to this one)
		# bash_to_call_R.sh
		# mutSigsDataPrep2.r
		# mutSigsSumMatrices.r
		# bash_to_call_SumMatrices.sh
	# Config file with variables for use in R scripts (mutSigsConfig.r - customize this)
	# Phenotype file with cancer types for your samples

# Pipeline summary:
	# VCF is split up in mutSigsMatrixPipeline.sh
	# VCF parts are converted from VCFs to matrices in mutSigsDataPrep2.r
	# Matrices are read back into R and summed for each cancer type in mutSigsSumMatrices.r

# Output:
	# Matrices for each VCF part
	# One summed matrix for each cancer type

# # set up environment
# module load sge
# module load gcc/4.8.4
# module load R/3.4.0

# parameters - input file name defined when script is run
inFile=$1
outDir=$2 # `pwd`

cd $outDir

# save headers
echo "Saving VCF headers"
if [ ! -a headers.txt ]; then # check for headers.txt file
	sed '/^#CHROM/q' $inFile > headers.txt
else
	echo "headers.txt file already exists!"
	exit 1
fi

# remove headers from variants
echo "Isolating variants from headers"
if [ ! -a vars.txt ]; then # check for vars.txt file
	sed '1,/^#CHROM/d' $inFile > vars.txt
else
	echo "vars.txt file already exists!"
	exit 1
fi

# split variants into 50,000 line chunks
echo "Splitting VCF"
split -a4 -l50000 vars.txt var_parts_

# combine the last two chunks in case the final one is <<50,000
last_file=`ls -t var_parts_* | head -n1`
second_last_file=`ls -t var_parts_* | head -n2 | tail -n1`
mv $second_last_file temp_last
cat temp_last $last_file  > $second_last_file
rm temp_last
rm $last_file

# put headers back on so that import into R works correctly
for f in var_parts_*; do 
	echo "Adding headers back to $f"
	cat headers.txt $f > "head_$f"
done
rm var_parts_*

# for each of the parts files, start a job that uses R to convert the VCF into a matrix
# for f in head_var_parts_*; do 
# 	qsub bash_to_call_R.sh $f $myDir
# done
#wait
	# bash_to_call_R.sh submits the job to the queue, and calls
	# mutSigsDataPrep.r, which cleans the data, groups by cancer type,
	# retrieves the motifs, and creates a matrix for each file submitted

# combine the motif matrices within each cancer type
# Will not work like this - it will be called when all jobs above are submitted,
# but before the jobs are done.  Need to have some flag to check periodically
# before running this.  For now run by hand.
#qsub bash_to_call_SumMatrices.sh $myDir
