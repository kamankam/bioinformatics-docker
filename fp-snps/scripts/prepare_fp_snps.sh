#!/bin/bash

# Convert the original GRAFSNP list to the required TSV format.
INPUT="$1"
OUTPUT="$(dirname "$INPUT")/FP_SNPs_10k_GB38_twoAllelsFormat.tsv"

awk -F '\t' 'BEGIN {
    OFS = "\t"
    print "#CHROM", "POS", "ID", "allele1", "allele2"
}
NR > 1 && $2 != 23 {
    print "chr"$2, $4, "rs"$1, $5, $6
}' "$INPUT" > "$OUTPUT"

