#!/bin/bash
#SBATCH --job-name="kmerfinder_batch_isolate" 
#SBATCH -A <partition>             
#SBATCH -p short                # Queue/partition
#SBATCH -t 01:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=18G    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=6     # Number of Cores (Processors/CPU)
#SBATCH --mail-user=<email>
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/<partition>/chx_wgs/log/"%x_%j.log"  
#SBATCH --error=/projects/<partition>/chx_wgs/log/"%x_%j.err"
     
# Load module
module purge
module load python-anaconda3/2019.10 singularity 

# Go to working directory
cd /projects/<partition>/chx_wgs

# Software directory
software_dir=/projects/<partition>/software/kmerfinder/
database_version=kmerfinder_db_20211017

# Specify input and output directory
# input_dir=spades_out
# output_dir=kmerfinder_out
input_dir=spades_isolate_out
output_dir=kmerfinder_isolate_out

while read -r sample
do
    # make directory for individual sample
    mkdir ${output_dir}/${sample}

    # Run kmerfinder
    singularity exec -B /projects/<partition>/ \
        ${software_dir}/kmerfinder_3.0.2.sif kmerfinder.py \
        -i ${input_dir}/${sample}/scaffolds.fasta \
        -o ${output_dir}/${sample} \
        -db ${software_dir}/kmerfinder_db/${database_version}/bacteria/bacteria.ATG \
        -tax ${software_dir}/kmerfinder_db/${database_version}/bacteria/bacteria.tax \
        -x
done < config/sample_sheet_kmerfinder.tsv



