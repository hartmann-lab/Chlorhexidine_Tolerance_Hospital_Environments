#!/bin/bash
#SBATCH --job-name="automlst_test_S5" 
#SBATCH -A p30892             
#SBATCH -p short                # Queue/partition
#SBATCH -t 01:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=28     # Number of Cores (Processors/CPU)
#SBATCH --mail-user=jiaxianshen2022@u.northwestern.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/p30892/chx_wgs/log/"%x_%j.log"  
#SBATCH --error=/projects/p30892/chx_wgs/log/"%x_%j.err"
     
#######################
# NOTE: This script only partially work. 
# The installation is complete.
# The script works. TIPS: You have to copy the input scaffolds.fasta into a separate empty folder (i.e., the folder only has this fasta file).
# But I decided to use the web version (https://automlst.ziemertlab.com/index) because (1) I do not understand how to properly use some flags according to the manual (e.g.,  --workflow {1,2} Workflow to use 1 or 2); (2) the output does not seem to have the image-format phylogenetic tree (TreeExport.svg), which is very helpful to view the closest-related organism; (3) interpreting taxonomic identification needs to be done individually for each sample.
#######################


# Load module
module purge all
module load anaconda3
source activate automlst


# Go to working directory
cd /projects/p30892/chx_wgs

# Software directory
software_dir=/projects/b1180/software/automlst

# Specify input and output directory
input_dir=test
output_dir=automlst_out
# input_dir=spades_isolate_out
# output_dir=kmerfinder_isolate_out

sample="S5"

# make directory for individual sample
mkdir ${output_dir}/${sample}

# Run automlst
python ${software_dir}/automlst.py \
    ${input_dir}/${sample} \
    ${output_dir}/${sample} \
    --refdb ${software_dir}/refseqreduced.db \
    --refdirectory ${software_dir}/automlstrefs \
    -c 28


source deactivate
