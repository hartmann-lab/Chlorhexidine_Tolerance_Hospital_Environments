#!/bin/bash
#SBATCH --job-name="quast_isolate" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 01:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"%x_%j.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"%x_%j.err"

# Load module
module purge all
module load quast/5.2.0

# Go to working directory
cd /projects/p30892/chx_wgs

# Specify input and output directory
# input_dir=spades_out
# output_dir=quast_out
input_dir=spades_isolate_out
output_dir=quast_isolate_out

while read -r sample
do
    # make directory for individual sample
    mkdir ${output_dir}/${sample}

    # Run quast
    quast \
        ${input_dir}/${sample}/scaffolds.fasta \
        -o ${output_dir}/${sample} \
        -t 28
done < config/sample_sheet_simple.tsv
