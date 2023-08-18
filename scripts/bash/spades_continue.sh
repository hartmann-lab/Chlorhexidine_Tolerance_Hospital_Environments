#!/bin/bash
#SBATCH --job-name="spades_continue" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 4:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     # Number of Cores (Processors/CPU)
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"spades_continue_%A_%a.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"spades_continue_%A_%a.err"
     

module purge
module load spades/3.15.0

# Go to working directory
cd /projects/p30892/chx_wgs

# Specify sample to continue and output directory
sample="S41"
output_dir=spades_out

spades.py \
    --continue \
    -o ${output_dir}/${sample}


