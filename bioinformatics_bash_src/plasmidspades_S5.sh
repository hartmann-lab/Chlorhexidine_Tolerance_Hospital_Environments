#!/bin/bash
#SBATCH --job-name="plasmidspades_S5" 
#SBATCH -A b1042             
#SBATCH -p genomicsguest                # Queue/partition
#SBATCH -t 7:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --ntasks-per-node=20     # Number of Cores (Processors/CPU)
#SBATCH --mem=100G    # --mem=0 means you take the whole node  
#SBATCH --mail-user=<email>
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/<partition>/chx_wgs/log/"%x_%j.log"  
#SBATCH --error=/projects/<partition>/chx_wgs/log/"%x_%j.err"
     
# Load module
module purge
module load spades/3.15.0

# Go to working directory
cd /projects/<partition>/chx_wgs

# Specify sample
sample="S5"
forward_read="fastp_out/${sample}_trimmed_paired_1.fastq.gz"
reverse_read="fastp_out/${sample}_trimmed_paired_2.fastq.gz"

mkdir -p plasmidspades_out/${sample}

# Run spades
spades.py \
    -1 $forward_read \
    -2 $reverse_read \
    --tmp-dir /projects/b1042/HartmannLab/js_chx_wgs/spades_temp \
    -o plasmidspades_out/${sample} \
    --cov-cutoff auto \
    -t 20 \
    --careful \
    --plasmid







