#!/bin/bash
#SBATCH --job-name="genomad" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 04:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"%x_%j.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"%x_%j.err"

#######################

#######################

# Load module (use the one Stefanie downloaded)
module purge all
module load mamba

source activate /projects/b1180/software/conda_envs/genomad

echo "Starting genomad job"

# Go to working directory
cd /projects/p30892/chx_wgs


# Set directory variables
input_dir=spades_selected_scaffolds
output_dir=genomad_out

while read -r sample
do
    # make directory for individual sample
    mkdir ${output_dir}/${sample}

    # Run bioinformatics tool
    genomad end-to-end --cleanup \
        ${input_dir}/${sample}/scaffolds.fasta \
        ${output_dir}/${sample} \
        /projects/b1180/software/conda_envs/genomad/genomad_db
done < ./config/sample_sheet_simple_selected.tsv


echo "Finishing genomad job"

