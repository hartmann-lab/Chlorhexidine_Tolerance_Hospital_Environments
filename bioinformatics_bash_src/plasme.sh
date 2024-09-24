#!/bin/bash
#SBATCH --job-name="plasme" 
#SBATCH -A <partition>             
#SBATCH -p short               # Queue/partition
#SBATCH -t 04:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     
#SBATCH --mail-user=<email>
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/<partition>/chx_wgs/log/"%x_%j.log"  
#SBATCH --error=/projects/<partition>/chx_wgs/log/"%x_%j.err"

module purge all
module load anaconda3
source activate plasme

echo "Job started!"


# Need to call PLASMe.py from its directory, where the DB is stored. 
cd /projects/b1180/software/PLASMe/


# Set other directory variables
parent_dir=/projects/<partition>/chx_wgs
input_dir=spades_selected_scaffolds
output_dir=plasme_out
temp_dir=/projects/b1042/HartmannLab/js_chx_wgs/plasme_temp


while read sample
do
    # Make a directory for output files and temporary files
    # If you are running multiple samples at the same time, make sure each sample has its own temp_dir. 
    # Otherwise temp files will be overwritten by processes of other samples and cause errors.  
    mkdir -p ${parent_dir}/${output_dir}/${sample}
    mkdir -p ${temp_dir}/${sample}

    # Run PLASMe
    python PLASMe.py \
        ${parent_dir}/${input_dir}/${sample}/scaffolds.fasta \
        ${parent_dir}/${output_dir}/${sample}/"plasme_out_${sample}.fasta" \
        --mode balance \
        --temp ${temp_dir}/${sample} \
        --thread 28
done < ${parent_dir}/config/sample_sheet_simple_selected.tsv



echo "Job finished!"