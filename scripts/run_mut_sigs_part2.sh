#!/bin/sh
#$ -S /bin/sh

# to run: 
# qsub -q xlong.q -j y -o /DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/repeat_analysis_lung_more_samples/pipeline_dev/mutect/ run_mut_sigs_part2.sh /DCEG/CGF/Bioinformatics/Production/Bari/Mut_sigs_EAGLE/repeat_analysis_lung_more_samples/pipeline_dev/mutect/config.yaml

configFile=$1

# note that this will only work for simple, single-level yaml
queue=$(awk '($0~/^queue/){print $2}' $configFile | sed "s/'//g")
execDir=$(awk '($0~/^execDir/){print $2}' $configFile | sed "s/'//g")
logDir=$(awk '($0~/^logDir/){print $2}' $configFile | sed "s/'//g")  # note that logDir is the only one that should not have a terminal slash
numJobs=$(awk '($0~/^numJobs/){print $2}' $configFile | sed "s/'//g")

if [ ! -d $logDir ]; then
	mkdir $logDir
fi

source /etc/profile.d/modules.sh
module load python3/3.5.1 sge

unset module  # this allows me to use -V in the qsub job below without getting the annoying bash_func_module errors in the output logs
conf=$configFile snakemake -s $execDir"Snakefile_mut_sigs_part2" --cluster "qsub -V -S /bin/sh -q $queue -o $logDir -j y" --jobs $numJobs --latency-wait 300 &> $logDir"/Snakefile_mut_sigs_part2.out"
