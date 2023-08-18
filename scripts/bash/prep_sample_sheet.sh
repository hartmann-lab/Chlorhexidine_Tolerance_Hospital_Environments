#!/bin/bash

# cut the dataset column
cut --complement -f2 config/sample_sheet_meta.tsv > config/temp.tsv 

# cut the first line
tail -n +2 config/temp.tsv > config/sample_sheet.tsv

rm config/temp.tsv