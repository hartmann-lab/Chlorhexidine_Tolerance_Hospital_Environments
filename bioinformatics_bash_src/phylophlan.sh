#!/bin/bash
#SBATCH --job-name="phylophlan_test" 
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

# Load module
module purge all
module load anaconda3
source activate phylophlan

# Inform CheckM of where the reference data files are placed


# Go to working directory
cd /projects/p30892/chx_wgs

# Specify input and output directory
input_dir=spades_out_scaffolds
output_dir=phylophlan_out


# make directory for individual sample
mkdir ${output_dir}/${sample}

# Run checkm Lineage-specific Workflow 
phylophlan -i <input_folder> \
    --output_folder ${output_dir}/${sample} \
    --genome_extension fasta \
    -d phylophlan \
    --diversity low \
    --accurate \
    -f <configuration_file> \
    --nproc 28
    



source deactivate

