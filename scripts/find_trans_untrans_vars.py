#!/usr/bin/env python3

# vcfs always report relative to the forward (pos) strand
# count a given mutation as transcribed vs. untranscribed based on which strand contains the pyrimidine
# for example, if you had N[A>G]N and N[C>T]N mutations on the transcribed strand, then you’d count one untranscribed T>C and one transcribed C>T


import sys
import argparse
import csv
import re
import os
# from string import maketrans

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

parser = argparse.ArgumentParser(description = 'Takes a VCF with either pos.vcf or neg.vcf in the filename and sorts variants into two files by whether the pyrimidine base is on the transcribed strand.')
parser.add_argument('infile', help='Input VCF file name')
parser.add_argument('outfile_trans', help='Output VCF file name for transcribed vars')
parser.add_argument('outfile_untrans', help='Output VCF file name for untranscribed vars')
results = parser.parse_args()

# check file exists
check_file(results.infile)

# inFileNoExt = os.path.splitext(results.infile)[0]
# tranFile = inFileNoExt + '_transcribed.vcf'
# untranFile = inFileNoExt + '_untranscribed.vcf'

# inTable = 'AG'
# outTable = 'TC'
# tranTable = maketrans(inTable, outTable)
 
ref = 3  # VCF structure (used instead of index numbers for readability)
alt = 4

with open(results.outfile_trans, 'w') as t, open(results.outfile_untrans, 'w') as u, open(results.infile, 'r') as r:
    csvreader = csv.reader(r, delimiter="\t")
    for line in csvreader:
        if re.search(r'#', line[0]):  # write headers to new files
            t.write('\t'.join(line) + '\n')
            u.write('\t'.join(line) + '\n')
        elif re.search(r'#', line[0]) is None:  # skip header rows
            # if len(line[ref]) != 1 or len(line[alt]) != 1:           # if there's anything other than an SNV, exit the script
            #     print("ERROR: This VCF contains non-SNV entries.")
            #         sys.exit()
            if 'pos.vcf' in results.infile:  # pos strand file (sense genes)
                if line[ref] in ('C', 'T'):  # if pyrimidine (C and T), count as transcribed mutation
                    t.write('\t'.join(line) + '\n')
                elif line[ref] in ('A', 'G'):  # if purine (G and A), convert to pyrimidine and count as untranscribed mutation
                    # line[ref] = line[ref].translate(tranTable)
                    # line[alt] = line[alt].translate(tranTable)
                    u.write('\t'.join(line) + '\n')
            elif 'neg.vcf' in results.infile: # neg strand file (anti-sense genes)
                if line[ref] in ('C', 'T'):  # if pyrimidine (C and T), count as untranscribed mutation
                    u.write('\t'.join(line) + '\n')
                elif line[ref] in ('A', 'G'):  # if purine (G and A), convert to pyrimidine and count as transcribed mutation
                    # line[ref] = line[ref].translate(tranTable)
                    # line[alt] = line[alt].translate(tranTable)
                    t.write('\t'.join(line) + '\n')
