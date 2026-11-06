#!/bin/bash
# Split GRCh38.d1.vd1 into 25 main chromosome FASTA files.

set -e

REF_DIR="$1"

INPUT="$REF_DIR/GRCh38.d1.vd1.fa"
OUTPUT_DIR="$REF_DIR/GRCh38.d1.vd1_mainChr/sepChrs"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting reference genome splitting..."

mkdir -p "$OUTPUT_DIR"

awk -v outdir="$OUTPUT_DIR" '
/^>/ {
    if (output != "") close(output)

    chr = $1
    sub(/^>/, "", chr)

    if (chr ~ /^chr([1-9]|1[0-9]|2[0-2]|X|Y|M)$/) {
        output = outdir "/" chr ".fa"
    } else {
        output = ""
    }
}
output != "" {
    print > output
}
' "$INPUT"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Reference genome splitting completed."

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting FASTA indexing..."

# Create a FASTA index for each chromosome.
for fasta in "$OUTPUT_DIR"/chr*.fa; do
    samtools faidx "$fasta"
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] FASTA indexing completed."
