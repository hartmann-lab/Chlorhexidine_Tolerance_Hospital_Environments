#!/bin/bash

# copy scaffolds from from_dir to to_dir

# Go to working directory
cd /projects/<partition>/chx_wgs

# from_dir=spades_out
# to_dir=spades_out_scaffolds
from_dir=spades_isolate_out
to_dir=spades_isolate_out_scaffolds

while read sample
do
    mkdir ${to_dir}/${sample}

    cp ${from_dir}/${sample}/scaffolds.fasta ${to_dir}/${sample}
done < config/sample_sheet_simple.tsv