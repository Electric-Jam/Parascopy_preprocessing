# Genotype Matrix Extraction and Processing

This script processes gzipped res.samples files containing CNV data to extract genotype matrices for agCN (allele-specific copy number) and psCN (phase-specific copy number) values.
It also provides options for filtering exonic intervals and handling duplication and deletion events.

## Features

- Read and process gzipped BED files.
- Create genotype matrices for agCN and psCN values.
- Filter exonic intervals.
- Handle duplication and deletion variants.
- Collapse genotype matrices by gene.

## Requirements

- Python 3.6+
- pandas
- gzip
- argparse
- os
- collections
- pyensembl

## Installation

Install the required Python packages using pip:

```sh
pip install pandas pyensembl


## Arguments
--directory: Path to the directory containing gzipped BED files (required).
--isExonic: Boolean flag to filter exonic intervals (required).
--isDuplication: Boolean flag to handle duplication intervals (required).
--isDeletion: Boolean flag to handle deletion intervals (required).
--output: Path to the output CSV file (required).


## Output
The script generates the following output files:

<output_path>_agCN.tsv: Combined genotype matrix for agCN values.
<output_path>_psCN_Dup.tsv: Combined genotype matrix for psCN duplication values.
<output_path>_psCN_Del.tsv: Combined genotype matrix for psCN deletion values.