#!/usr/bin/env python3

# detect dinucleotide mutations

# Dinucleotide substitutions were identified when two substitutions were present in consecutive bases on the same chromosome (sequence context was ignored). 

    # assuming a sorted SNV-only vcf:
        # for each column, if adjacent rows have a non-wt and non-missing genotype, check chr and pos

import sys
import argparse
import csv
import re
#import itertools

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

parser = argparse.ArgumentParser(description = 'Counts the number of dincleotide substitutions per sample in a VCF, and returns the sample IDs and counts in a tab-delimited file.')
parser.add_argument('infile', help='Input VCF file name')
parser.add_argument('outfile', help='Output file name')
results = parser.parse_args()

# check file exists
check_file(results.infile)

pos = 1  # VCF structure (used instead of index numbers for readability)
ref = 3
alt = 4

previousLine = ""

with open(results.infile, 'r') as file:
    csvreader = csv.reader(file, delimiter="\t")
    for line in csvreader:                          # reads in line as list
        if re.search(r'#CHROM', line[0]):               # if it's the header row:
            samples = [s for s in line[9:len(line)]]    # list of samples found in header row
            dinucCounts = dict.fromkeys(samples, 0)     # make a dict that stores sample name as key, number of dinucleotide SNVs as value
            headerFlag = True
        elif re.search(r'#', line[0]) is None and headerFlag:    # if it's not any of the header rows:
            if len(line[ref]) != 1 or len(line[alt]) != 1:           # if there's anything other than an SNV, exit the script
                print("ERROR: This VCF contains non-SNV entries.")
                sys.exit()
            else:
                if previousLine == "":          # for the very first line of data, just save it as the previousLine, then go to the next line
                    previousLine = line
                else:   
                    if line[0] == previousLine[0] and int(line[pos]) - int(previousLine[pos]) == 1:       # if the two adjacent lines affect adjacent nucleotides
                        for geno1,geno2,s in zip(line[9:len(line)],previousLine[9:len(previousLine)],samples):  # note that in python3, zip behaves like python2 itertools.izip
                            if geno1.startswith("0/1") and geno2.startswith("0/1"):
                                dinucCounts[s] += 1
                    previousLine = line

if headerFlag:
    with open(results.outfile, 'w') as f:
        for key, value in dinucCounts.items():
            f.write('%s\t%s\n' % (key,value))        # write results to tab-delimited file
else:
    print("ERROR: No header row detected.")
    sys.exit()

