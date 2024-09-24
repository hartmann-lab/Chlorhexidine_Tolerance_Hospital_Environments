#!/bin/bash
#SBATCH --job-name="chx_wgs_fastqc" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 00:40:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=18G    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=6     # Number of Cores (Processors/CPU)
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"chx_wgs_fastqc.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"chx_wgs_fastqc.err"
     

module purge
module load fastqc/0.11.5  # use the quest module fastqc

cd /projects/p30892/chx_wgs


while read -r sample forward_read reverse_read
do
	fastqc -t 6 \
		$forward_read \
		$reverse_read \
		--outdir fastqc_out/
done < config/sample_sheet.tsv

