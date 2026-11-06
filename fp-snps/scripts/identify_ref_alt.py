
import pysam
import csv
import argparse
import logging

# Command-line arguments
parser = argparse.ArgumentParser(description="Identify REF and ALT alleles using GRCh38.")
parser.add_argument("-i", "--input", required=True, help="Input TSV file")
parser.add_argument("-o", "--output", required=True, help="Output TSV file")
parser.add_argument("-r", "--reference-dir", required=True, help="Directory with chromosome FASTA files")
parser.add_argument("--log", required=True, help="Output log file")
args = parser.parse_args()

input_path = args.input
output_path = args.output
ref_dir = args.reference_dir
log_path = args.log


# Write logs to both the terminal and a file
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s: %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(log_path, mode="w", encoding="utf-8")
    ]
)
logging.info("Starting SNP processing")
logging.info("Input file: %s", input_path)
logging.info("Output file: %s", output_path)

# No reference file is open yet
current_chrom = None
fasta = None

# Count matched and mismatched SNPs
matched_count = 0
mismatched_count = 0

# Read SNPs from the input file
with open(input_path, "r", encoding="utf-8", newline="") as input_file:
    reader = csv.DictReader(input_file, delimiter="\t")

    # Check the input file header
    expected_header = ["#CHROM", "POS", "ID", "allele1", "allele2"]
    if reader.fieldnames != expected_header:
        raise ValueError(
            f"Invalid input header. Expected: {', '.join(expected_header)}"
        )

    # Write results to the output file
    with open(output_path, "w", encoding="utf-8", newline="") as output_file:
        writer = csv.writer(output_file, delimiter="\t")
        writer.writerow(["#CHROM", "POS", "ID", "REF", "ALT"])

        for snp in reader:
            # Get SNP information from the input table
            chrom = snp["#CHROM"]

            # Open a new FASTA when the chromosome changes
            if chrom != current_chrom:
                if fasta is not None:
                    fasta.close()

                fasta_path = f"{ref_dir}/{chrom}.fa"
                fasta = pysam.FastaFile(fasta_path)
                current_chrom = chrom
                logging.info("Opened reference FASTA: %s", fasta_path)

            # Get SNP position, ID and alleles
            pos = int(snp["POS"])
            snp_id = snp["ID"]
            allele1 = snp["allele1"]
            allele2 = snp["allele2"]

            # Get the reference base at the SNP position
            ref_base = fasta.fetch(chrom, pos - 1, pos)

            # Identify the reference and alternative alleles
            if ref_base == allele1:
                ref = allele1
                alt = allele2
                matched_count += 1
            elif ref_base == allele2:
                ref = allele2
                alt = allele1
                matched_count += 1
            else:
                ref = None
                alt = None
                mismatched_count += 1
                logging.warning(
    "Reference mismatch for %s at %s:%s (alleles: %s/%s, reference: %s)",
    snp_id, chrom, pos, allele1, allele2, ref_base
)

            # Write the SNP to the output file
            writer.writerow([chrom, pos, snp_id, ref, alt])
            

# Close the last FASTA file
if fasta is not None:
    fasta.close()

# Print the final counts
logging.info("Total SNPs: %d", matched_count + mismatched_count)
logging.info("Matched SNPs: %d", matched_count)
logging.info("Mismatched SNPs: %d", mismatched_count)
logging.info("SNP processing completed")
