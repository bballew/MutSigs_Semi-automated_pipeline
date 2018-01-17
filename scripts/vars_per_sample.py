#!/usr/bin/env python3

import sys
import argparse
import csv
import re
import itertools

#####################################################################################################
############################################# Functions #############################################
#####################################################################################################

def check_file(fname):
	"""Check that file can be read and exit with error message if it can not."""

	try:
		f = open(fname, 'rb')
	except IOError:
		print("Could not read file", fname)
		sys.exit()

	f.close()

#####################################################################################################

def count_vars_per_sample(infile, outfile):
	"""Count the number of non-reference variants per sample and print results to file."""

	samples = [] 				# list to hold the sample names from the vcf header row
	varCounts = {} 				# dictionary to hold sample names (key) and non-ref variant counts (value)
	headerFlag = False			# flag to check whether you've found the required #CHROM line

	with open(infile) as file:
		for line in csv.reader(file, delimiter = "\t"):								# reads line in as list
			if re.search(r'#CHROM', line[0]):										# for the #CHROM header row
				samples = [s for s in line[9:len(line)]]							# populate list of sample names from vcf
				varCounts = dict.fromkeys(samples, 0)								# build dictionary with sample names as keys, default values of 0
				headerFlag = True

			if re.search(r'#', line[0]) is None and headerFlag:						# for variant rows
				for s,genotype in zip(samples,line[9:len(line)]):					# concurrently iterate over the list of sample names and the genotype columns in each row
					if not (genotype.startswith('.') or genotype.startswith('0/0')): # if the genotype is not wt or missing

						varCounts[s] += 1											# add one to the varCount value for that sample name
	
	if headerFlag:
		with open(outfile, 'w') as f:
			for key, value in varCounts.items():
				f.write('%s\t%s\n' % (key,value))											# write results to tab-delimited file
	else:
		print("No header row detected.")
		sys.exit()

#####################################################################################################

parser = argparse.ArgumentParser(description = 'Counts the number of non-reference calls per sample in a VCF, and returns the sample IDs and counts in a tab-delimited file.')
parser.add_argument('input_vcf', help='Input VCF file name')
parser.add_argument('outfile', help='Output VCF file name')
results = parser.parse_args()

# check file exists

check_file(results.input_vcf)

# count the non-reference variants for each sample

count_vars_per_sample(results.input_vcf, results.outfile)





