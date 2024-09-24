#!/bin/bash
#SBATCH --job-name="rgi_on_genomad_virus_seq" 
#SBATCH -A p30892             
#SBATCH -p short               # Queue/partition
#SBATCH -t 04:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     
#SBATCH --mail-user=jiaxian.shen@northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"%x_%j.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"%x_%j.err"

#######################
# Input: virus sequences identified by geNomad
# Run rgi
#######################

# Load module
module purge all
module load anaconda3
source activate rgi


# Set directory variables
parent_dir=/projects/p30892/chx_wgs
input_dir=genomad_out
output_dir=rgi_on_genomad_virus_seq_out

database_dir=/projects/p30892/software/rgi

# load database
rgi clean --local
rgi load --card_json ${database_dir}/card.json --local

# All use absolute path specfied by the above section
while read sample
do
    # make directory for individual sample
    mkdir ${parent_dir}/${output_dir}/${sample}

    # Run 
    rgi main \
        --input_sequence ${parent_dir}/${input_dir}/${sample}/scaffolds_summary/scaffolds_virus.fna \
        --output_file ${parent_dir}/${output_dir}/${sample}/"rgi_on_genomad_virus_seq_${sample}" \
        --local \
        --clean \
        --num_threads 28 \
        --split_prodigal_jobs \
        --include_loose

done < ${parent_dir}/config/sample_sheet_simple_selected.tsv


source deactivate

