#!/bin/bash
#SBATCH --job-name="fastqc_for_fastp_ed_reads" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 04:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     # Number of Cores (Processors/CPU)
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"fastqc_for_fastp_ed_reads.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"fastqc_for_fastp_ed_reads.err"
     

module purge
module load fastqc/0.11.5  # use the quest module fastqc

cd /projects/p30892/chx_wgs


while read -r sample
do
	forward_read=fastp_out/${sample}_trimmed_paired_1.fastq.gz
	reverse_read=fastp_out/${sample}_trimmed_paired_2.fastq.gz

	fastqc -t 28 \
		$forward_read \
		$reverse_read \
		--outdir fastqc_reads_after_fastp_out/
done < config/sample_sheet_simple.tsv

