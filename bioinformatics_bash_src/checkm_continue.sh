#!/bin/bash
#SBATCH --job-name="checkm_continue" 
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
# I haven't figured out how to get the plot functions to work. It seems that the Utility Commands have to be run prior to plotting. Some utility commands require prerequisite files. For example, the coverage function requires indexed and sorted BAM files produced with a tool such as BWA. 
# The KBase version checkM can output plots. But it has limited threads (possibly 4).
# The CheckM_summary_table.tsv can be output by -f flag.
#######################

# Load module
module purge all
module load anaconda3
source activate checkm

# Inform CheckM of where the reference data files are placed
checkm data setRoot /projects/b1180/software/checkm_reference_data/checkm_data_2015_01_16

# Go to working directory
cd /projects/p30892/chx_wgs

# Specify input and output directory
input_dir=spades_out_scaffolds
output_dir=checkm_out

while read -r sample
do
    # make directory for individual sample
    mkdir ${output_dir}/${sample}

    # Run checkm Lineage-specific Workflow 
    checkm lineage_wf \
        -t 28 \
        -x fasta \
        --tab_table \
        -f ${output_dir}/${sample}/CheckM_summary_table.tsv \
        ${input_dir}/${sample} \
        ${output_dir}/${sample}
done < config/sample_sheet_simple_continue.tsv


source deactivate

