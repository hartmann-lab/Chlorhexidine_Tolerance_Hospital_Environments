#!/bin/bash
#SBATCH --job-name="spades_S5" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 4:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     # Number of Cores (Processors/CPU)
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"chx_wgs_spades_S5.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"chx_wgs_spades_S5.err"
     
# Load module
module purge
module load spades/3.15.0

# Go to working directory
cd /projects/p30892/chx_wgs

# Specify sample
sample="S5"
forward_read="fastp_out/${sample}_trimmed_paired_1.fastq.gz"
reverse_read="fastp_out/${sample}_trimmed_paired_2.fastq.gz"

mkdir spades_out/${sample}

# Run spades
spades.py \
    -1 $forward_read \
    -2 $reverse_read \
    --tmp-dir /projects/b1042/HartmannLab/js_chx_wgs/spades_temp \
    -o spades_out/${sample} \
    --cov-cutoff auto \
    -t 28 \
    --careful







