#!/bin/bash
#SBATCH --job-name="phylophlan_test_3_samples" 
#SBATCH -A <partition>             
#SBATCH -p short               # Queue/partition
#SBATCH -t 02:00:00             # Walltime/duration of the job
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
source activate phylophlan



# Set directory variables
parent_dir=/projects/<partition>/chx_wgs
# input_dir=spades_out_scaffolds
input_dir=spades_out_scaffolds
output_dir=phylophlan_metagenomic_out
database_dir=/projects/<partition>/software/phylophlan/phylophlan_databases

# All use absolute path specfied by the above section
while read sample
do
    # make directory for individual sample
    mkdir ${parent_dir}/${output_dir}/${sample}
    
    # Go to sample output directory
    cd ${parent_dir}/${output_dir}/${sample}

    # Run 
    phylophlan_metagenomic \
        -i ${parent_dir}/${input_dir}/${sample} \
        -o ${sample} \
        --database_folder ${database_dir} \
        --nproc 28 \
        -n 20 \
        -d SGB.Jul20
done < ${parent_dir}/config/sample_sheet_simple_test.tsv


source deactivate

