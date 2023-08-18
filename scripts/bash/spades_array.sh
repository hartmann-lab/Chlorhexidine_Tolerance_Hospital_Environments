#!/bin/bash
#SBATCH --job-name="spades__array" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 4:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     # Number of Cores (Processors/CPU)
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"spades_array_%A_%a.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"spades_array_%A_%a.err"
#SBATCH --array=1-48%8


# Spades flag: --careful


sleep $(echo "$RANDOM / 36000 * 60" | bc -l | xargs printf "%.0f")

# Load module
module purge all
module load spades/3.15.0

echo "Starting spades job"

# Go to working directory
cd /projects/p30892/chx_wgs

# Specify sample config
sample_sheet_store=config/sample_sheet_spades.tsv
sample=$(cat $sample_sheet_store | awk -v var=$SLURM_ARRAY_TASK_ID 'NR==var {print $1}')

# Specify input and output directory
input_dir=fastp_out
output_dir=spades_out
temp_dir=/projects/b1042/HartmannLab/js_chx_wgs/spades_temp


n=$(printf "%04d" $SLURM_ARRAY_TASK_ID)

# make directory for individual sample
mkdir ${output_dir}/${sample}
mkdir ${temp_dir}/${sample}

# Run spades
spades.py \
    -1 ${input_dir}/${sample}_trimmed_paired_1.fastq.gz \
    -2 ${input_dir}/${sample}_trimmed_paired_2.fastq.gz \
    --tmp-dir ${temp_dir}/${sample} \
    -o ${output_dir}/${sample} \
    --cov-cutoff auto \
    -t 28 \
    --careful


echo $sample
echo $n
echo "Finishing spades job"










