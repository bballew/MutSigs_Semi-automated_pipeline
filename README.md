# MutSigs_Semi-automated_pipeline
From single-sample VCFs to mutational signatures graphs

# Description of pipeline

## Part 1

Snakefile_mut_sigs_part1 incorporates:

- Input organization (bgzipping, header removal/addition)
- Data exploration and plotting (variant counts per chrom, per subject - pre and post filtering)
- Data cleaning (removal of germline columns, non-canonical chroms)
- Merging into a single multi-sample VCF
- Annotation (via Mingyi's tool) and filtering
- Summarizing of data metrics for QC (variant counts, line counts, variant counts by type - SNV, indel, etc)

## Part 2

__The user should have reviewed the outputs of the previous pipeline (especially those in summary_data/) prior to running part2, and should determine which samples shall be included in these next steps.  For example, if there are multiple tumor samples per germline, the user will need to either run part2 on the full set of tumor samples, or choose a subset, edit the vcf output from part1 accordingly, and then run part2.__

Snakefile_mut_sigs_part2 incorporates:

- Input organization/parallelization (bgzipping, splitting by chromosome)
- Conversion from VCF to motif matrix in R format
    - One matrix for each group as defined in the config file (which should match the group annotations in the phenotype file)
    - An additional matrix with all individuals across all groups, where the individual IDs are prepended with the group
- Conversion of motif matrix from R format to MATLAB format
- Running SomaticSignatures R package for 1 to 15 signatures to generate a signature stability/variance plot

## Part 3

__The user should have reviewed the plots from part2 to determine the number of signatures, and updated the config file as needed.__

Snakefile_mut_sigs_part2 incorporates:

- Finding n somatic signatures, where n is a user-defined number, for each group (defined above) and for all samples together
- Outputting a table with the values from the above analysis as well as plots

# Input requirements

## Part 1

- User-edited config.yaml file
- Text file that lists the VCFs to analyze (base name only, no path or extension; currently tested only with MuTect and MuTect2 output)
    - E.g.:
    
            ABCD_person1_tumor1
            ABCD_person1_tumor2
            ABCD_person1_tumor3
            ABCD_person3_tumor1
            ABCD_person5_tumor12
    
- VCFs listed above (bgzipped or not ok)
- Pipeline scripts
- Appropriately configured variant annotation tool via annotation_config.rc (Mingyi's tool - e.g., temp directory set, queues set, etc.)

## Part 2

- User-edited config.yaml file (same file as for part1)
- Phenotype file matching each individual ID to a group
    - Space-delimited
    - With header
    - You will specify which column headers represent the VCF name and the group designation in the config file
    - E.g.:
    
            Sample Group_assignment Some_other_stuff
            ABCD_person1_tumor1 Lung stuff
            ABCD_person1_tumor2 Lung stuff
            ABCD_person1_tumor3 Lung stuff
            ABCD_person3_tumor1 Breast stuff
            ABCD_person5_tumor12 Pancreas stuff
            
- Filtered multi-sample VCF (generated in part1)

## Part 3

- User-edited config.yaml file (same file as for part1 and part2)
- Motif matrices created in part2

# Running the pipeline

Interactively (for testing purposes only):

    conf=</path/to/config.yaml> snakemake -s </path/to/Snakefile_mut_sigs_part[1-3]>

    E.g.:  conf=/DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/repeat_analysis_lung_more_samples/pipeline_dev/mutect/config.yaml snakemake -n -s /DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/repeat_analysis_lung_more_samples/pipeline_dev/pipeline/Snakefile_mut_sigs_part3

As a submitted job:

    qsub -q <queue> -j y -o </path/to/where/you/want/this/log/> run_mut_sigs_part[1-3].sh </path/to/config.yaml>

    E.g.:  qsub -q xlong.q -j y -o /DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/repeat_analysis_lung_more_samples/pipeline_dev/mutect/ run_mut_sigs_part3.sh /DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/repeat_analysis_lung_more_samples/pipeline_dev/mutect/config.yaml
