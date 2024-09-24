import os
import glob
import argparse
import pandas as pd
import numpy as np


# Create argument parse
parser = argparse.ArgumentParser(
    description='Merge output sheets into one.'
    )
parser.add_argument('--indir', help="Path to the input directory",
                    type=str
                    )
parser.add_argument('--config_file', help='Config file (e.g., list of sample id)',
                    type=str,
                    default="config/sample_sheet_simple.tsv"
                    )
parser.add_argument("--outdir", help="Path to the output directory",
                    default="merged_table"
                    )
parser.add_argument("--target_file_name", 
                    help="File name to be merged",
                    type=str
                    )
parser.add_argument("--output_file_name", 
                    help="Output file name. If not specified, the input directory will be used.",
                    type=str
                    )
args = parser.parse_args()



sample_list = np.loadtxt(args.config_file, delimiter="\t", dtype=str)

df_concat = pd.DataFrame([])

for ii in sample_list:
    path = args.indir + "/" + ii + "/" + args.target_file_name
    tsv = pd.read_csv(path, sep='\t')
    tsv["sample"]=ii
    df_concat = pd.concat([df_concat, tsv])
    

if not args.output_file_name:
    args.output_file_name = "merged_" + args.indir + ".tsv"

# exporting to tsv
output_file_name = args.outdir + "/" + args.output_file_name

df_concat.to_csv(output_file_name, sep="\t", index = False)


