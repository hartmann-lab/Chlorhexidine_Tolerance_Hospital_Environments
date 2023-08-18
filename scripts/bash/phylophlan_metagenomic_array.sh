#!/bin/bash
#SBATCH --job-name="phylophlan_metagenomic_array" 
#SBATCH -A p30892             
#SBATCH -p short               # Queue/partition
#SBATCH -t 02:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/phylophlan_metagenomic/"phylophlan_metagenomic_array_%A_%a.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/phylophlan_metagenomic/"phylophlan_metagenomic_array_%A_%a.err"
#SBATCH --array=1-58%10

#######################

#######################

sleep $(echo "$RANDOM / 36000 * 60" | bc -l | xargs printf "%.0f")

# Load module
module purge all
module load anaconda3
source activate phylophlan

echo "Starting phylophlan_metagenomic job"


# Set directory variables
working_dir=/projects/p30892/chx_wgs
input_dir=spades_selected_scaffolds
output_dir=phylophlan_metagenomic_out
database_dir=/projects/p30892/software/phylophlan/phylophlan_databases


# Specify sample config
sample_sheet_store=${working_dir}/config/sample_sheet_simple_selected.tsv
sample=$(cat $sample_sheet_store | awk -v var=$SLURM_ARRAY_TASK_ID 'NR==var {print $1}')


n=$(printf "%04d" $SLURM_ARRAY_TASK_ID)


# make directory for individual sample
mkdir ${working_dir}/${output_dir}/${sample}

# Go to sample output directory
cd ${working_dir}/${output_dir}/${sample}

# Run 
phylophlan_metagenomic \
    -i ${working_dir}/${input_dir}/${sample} \
    -o ${sample} \
    --database_folder ${database_dir} \
    --nproc 28 \
    -n 20 \
    -d SGB.Jul20


echo $sample
echo $n
echo "Finishing phylophlan_metagenomic job"

source deactivate

