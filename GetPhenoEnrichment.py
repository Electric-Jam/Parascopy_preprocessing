#!/usr/bin/env python3

import argparse
import pandas as pd

def main():
    parser = argparse.ArgumentParser(
        description=(
            "Compute ICD10 code counts for a subset of sample IDs. "
            "The input file has three columns per row (row_number, sample_id, ICD10) "
            "after a header line that says 'eid ICD10'. "
            "You can specify sample IDs by providing one or more files, each with one ID per line, "
            "OR by listing the IDs directly on the command line."
        )
    )
    
    # Mutually exclusive group for specifying sample IDs
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--sample_ids_files",
        nargs="+",  # allow multiple files
        help="Paths to one or more files containing sample IDs (one ID per line)."
    )
    group.add_argument(
        "--sample_ids_list",
        nargs="+",
        help="Space-separated list of sample IDs directly on the command line, e.g. '--sample_ids_list 5067852 2197621'"
    )
    
    parser.add_argument(
        "--icd_data",
        required=True,
        help="Path to a file with a header line, followed by rows of (row_number, sample_id, pipe-delimited ICD10)."
    )
    parser.add_argument(
        "--output",
        required=True,
        help="Path to the output TSV file which will contain the ICD10 counts."
    )
    
    args = parser.parse_args()
    
    # --------------------------------------------------------
    # 1. Read the ICD data file
    # --------------------------------------------------------
    #   - Skip the first row ('eid ICD10') because it's not aligned
    #     with the actual columns below it.
    #   - We'll name the columns: row_number, eid, ICD10.
    # --------------------------------------------------------
    print(f"Reading ICD data from '{args.icd_data}'...")
    icd_data = pd.read_csv(
        args.icd_data, 
        sep=r"\s+",            # split by one or more whitespace
        header=None,           # no usable header for these columns
        names=["row_number", "eid", "ICD10"],
        skiprows=1,           # skip the first line "eid ICD10"
        dtype=str
    )
    
    # --------------------------------------------------------
    # 2. Collect sample IDs from either files or a direct list
    # --------------------------------------------------------
    if args.sample_ids_files:
        # If multiple files are given, read them all
        sample_ids = []
        for filepath in args.sample_ids_files:
            print(f"Reading sample IDs from file '{filepath}'...")
            with open(filepath, "r") as f:
                for line in f:
                    line = line.strip()
                    if line:
                        sample_ids.append(line)
        # Remove duplicates if you want a unique set of IDs
        sample_ids = list(set(sample_ids))
        print(f"Total unique sample IDs from all files: {len(sample_ids)}")
    else:
        # sample_ids_list was used
        print(f"Using sample IDs specified on the command line: {args.sample_ids_list}")
        sample_ids = args.sample_ids_list
    
    # --------------------------------------------------------
    # 3. Filter the ICD data to keep only rows whose eid is in sample_ids
    # --------------------------------------------------------
    print("Filtering ICD data to include only specified sample IDs...")
    filtered_icd_data = icd_data[icd_data["eid"].isin(sample_ids)].copy()
    
    # --------------------------------------------------------
    # 4. Split ICD10 codes by '|' and expand the table
    #    so each code is on its own row
    # --------------------------------------------------------
    # Handle missing/empty values gracefully
    filtered_icd_data["ICD10"] = filtered_icd_data["ICD10"].fillna("")
    filtered_icd_data["ICD10_list"] = filtered_icd_data["ICD10"].str.split("|")
    exploded_icd_data = filtered_icd_data.explode("ICD10_list")
    
    # --------------------------------------------------------
    # 5. Count how often each ICD10 code appears
    # --------------------------------------------------------
    icd_counts = (
        exploded_icd_data
        .groupby("ICD10_list")
        .size()
        .reset_index(name="count")
        .sort_values("count", ascending=False)
    )
    
    # Rename column for clarity
    icd_counts.rename(columns={"ICD10_list": "ICD10"}, inplace=True)
    
    # --------------------------------------------------------
    # 6. Write out the result as a tab-delimited file
    # --------------------------------------------------------
    print(f"Writing results to '{args.output}'...")
    icd_counts.to_csv(args.output, sep="\t", index=False)
    
    print("Done!")

if __name__ == "__main__":
    main()
