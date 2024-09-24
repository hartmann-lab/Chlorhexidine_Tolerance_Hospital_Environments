#!/bin/bash
#SBATCH --job-name="mobile_element_finder" 
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

#######################

#######################

# Load module
module purge all
module load anaconda3
source activate mefinder  # conda env

echo "Job started!"

# Set directory variables
cd /projects/<partition>/chx_wgs/

input_dir=spades_selected_scaffolds
output_dir=mobile_element_finder_out


# My script - mefinder
while read sample
do
    # make directory for individual sample in output directory
    mkdir ${output_dir}/${sample}

    # make directory for individual temp files
    mkdir /projects/b1042/HartmannLab/js_chx_wgs/mefinder_temp/${sample}

    # Run
    mefinder find --contig ${input_dir}/${sample}/scaffolds.fasta \
        ${output_dir}/${sample}/${sample} \
        -t 28 \
        --temp-dir /projects/b1042/HartmannLab/js_chx_wgs/mefinder_temp/${sample} \
        -g
done < ./config/sample_sheet_simple_selected.tsv

source deactivate

echo "Job finished!"





