#!/bin/bash

# copy files from from_dir to to_dir

# Go to working directory
cd /projects/p30892/chx_wgs

# from_dir=spades_out
# to_dir=spades_out_scaffolds
from_dir=phylophlan_metagenomic_out
to_dir=phylophlan_metagenomic_out_just_reports

while read sample
do
    cp ${from_dir}/${sample}/${sample}.tsv ${to_dir}/
done < config/sample_sheet_simple_selected.tsv