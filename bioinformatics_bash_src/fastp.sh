#!/bin/bash
#SBATCH --job-name="chx_wgs_fastp" 
#SBATCH -A <partition>             
#SBATCH -p short                # Queue/partition
#SBATCH -t 04:00:00             # Walltime/duration of the job
#SBATCH -N 1                    # Number of Nodes
#SBATCH --mem=0    # --mem=0 means you take the whole node  
#SBATCH --ntasks-per-node=24     # 24 is the max
#SBATCH --mail-user=<email>
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --output=/projects/<partition>/chx_wgs/log/"chx_wgs_fastp.log"  
#SBATCH --error=/projects/<partition>/chx_wgs/log/"chx_wgs_fastp.err"
     

module purge
 
module load anaconda3
source activate assembly

cd /projects/<partition>/chx_wgs


while read -r sample forward_read reverse_read
do
    fastp \
            --in1 $forward_read \
            --in2 $reverse_read \
            --out1 fastp_out/${sample}_trimmed_paired_1.fastq.gz \
            --out2 fastp_out/${sample}_trimmed_paired_2.fastq.gz \
            --unpaired1 fastp_out/${sample}_trimmed_unpaired_1.fastq.gz \
            --unpaired2 fastp_out/${sample}_trimmed_unpaired_2.fastq.gz \
            -h fastp_out/${sample}_fastp.html \
            -j fastp_out/${sample}_fastp.json \
            -w 24
done < config/sample_sheet.tsv


source deactivate
