#!/usr/bin/env python3

import requests
import json
import argparse
import os


MUTAGENE_URL = "https://www.ncbi.nlm.nih.gov/research/mutagene"


def get_profile(fname, assembly=19):
    """
    Calling MutaGene REST API to convert a VCF file into a mutational profile (96 context-dependent mutational probabilities)
    and profile_counts (counts of mutations for each of the 96 context-dependent mutations)
    It is important to specify genome assembly correctly. Curently 19, 37 and 38 will work
    """
    url = MUTAGENE_URL + '/pub/api/identify/profile'
    files = {'file': open(fname, 'rb')}
    r = requests.post(url, files=files, data={'assembly': assembly})
    # print("STATUS", r.status_code)
    if r.status_code == 200:
        return r.json()['result_counts']


def get_decomposition(profile_counts, signatures='COSMIC30'):
    """
    Decomposition of mutational profiles into a combination of signatures.
    It is highly recommended to use profile_counts instead of profile in order to use Maximum Likelihood method

    *signatures* should be one of COSMIC30  MUTAGENE5 MUTAGENE10
    *others_threshold* is used for not reporting signatures with exposure less or equal than the threshold and reporting the sum of their exposures as "Other signatures".
    Set *others_threshold* to 0 if not needed. The MutaGene website uses others_threshold = 0.05 by default.
    """
    url = MUTAGENE_URL + '/pub/api/identify/decomposition'
    r = requests.post(url, data={'profile_counts': json.dumps(profile_counts), 'signatures': signatures, 'others_threshold': 0.0})
    # print("STATUS", r.status_code)
    if r.status_code == 200:
        return r.json()['decomposition']


# def print_profile_counts(profile_counts):
#     """
#     Printing context-dependent mutational profile
#     """
#     for mutation, value in profile.items():
#         print("{}\t{:.0f}".format(mutation, value))
#     print()


# def print_decomposition(decomposition):
#     """
#     Printing the results of decomposition
#     """
#     for component in decomposition:
#         print("{}\t{:.2f}\t{:.0f}".format(component['name'], component['score'], component['mutations']))
#     print()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Runs list of single-sample VCFs through MutaGene via API.')
    parser.add_argument('-l', nargs='+', help='Input VCF file name list')
    #parser.add_argument('-i', help='Input directory')
    parser.add_argument('-o', help='Output directory')
    args = parser.parse_args()

    for file in args.l:
        base = os.path.basename(file)
        #inFile = args.i + file + '.vcf'
        outFile = args.o + os.path.splitext(base)[0] + '.mutagene.txt'
        
        with open(outFile, 'w') as out:
            profile = get_profile(file, assembly=19)
            for mutation, value in profile.items():
                out.write("{}\t{:.0f}\n".format(mutation, value))
            out.write('\n')

            if profile is not None:
                for signature_type in ('COSMIC30', 'MUTAGENE5', 'MUTAGENE10'):
                        decomposition = get_decomposition(profile, signature_type)
                        for component in decomposition:
                            out.write("{}\t{:.2f}\t{:.0f}\n".format(component['name'], component['score'], component['mutations']))
                        out.write('\n')
