
import pysam
import csv

# Reference genome and input SNP file
ref_dir = "/ref/GRCh38.d1.vd1_mainChr/sepChrs"
input_path = "/work/fp-snps/data/FP_SNPs_10k_GB38_twoAllelsFormat.tsv"

# No reference file is open yet
current_chrom = None
fasta = None

# Count matched and mismatched SNPs
matched_count = 0
mismatched_count = 0

# Read SNPs from the input file.
with open(input_path, "r", encoding="utf-8") as input_file:
    reader = csv.DictReader(input_file, delimiter="\t")
    for snp in reader:
        # Get SNP information from the input table
        chrom = snp["#CHROM"]
        # Switch the reference FASTA when the chromosome changes
        if chrom != current_chrom:
            if fasta is not None:
                fasta.close()
            fasta_path = f"{ref_dir}/{chrom}.fa"
            fasta = pysam.FastaFile(fasta_path)
            current_chrom = chrom
            print("Opened reference FASTA:", fasta_path)
        # Get SNP position, ID and alleles
        pos = int(snp["POS"])
        snp_id = snp["ID"]
        allele1 = snp["allele1"]
        allele2 = snp["allele2"]

        # Get the reference base at the SNP position
        ref_base = fasta.fetch(chrom, pos - 1, pos)
        print("Reference nucleotide:", ref_base)

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
            print("Warning: neither allele matches the reference genome.")
        
        print(snp_id, chrom, pos, "REF:", ref, "ALT:", alt)

# Close the last FASTA file
if fasta is not None:
    fasta.close()

# Print the final counts
print("Total SNPs:", matched_count + mismatched_count)
print("Matched SNPs:", matched_count)
print("Mismatched SNPs:", mismatched_count)