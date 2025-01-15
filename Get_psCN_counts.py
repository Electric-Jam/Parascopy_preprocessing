#!/usr/bin/env python3

import os
import gzip
import pandas as pd
from glob import glob
from collections import defaultdict

def build_psCN_count_table(
    input_dir,
    sample_id_file=None,
    exclude_sample_files=None,  # list of paths
    gene_names=None,
    output_file=None,
    partial_gene_match=False
):
    """
    Build a table of merged overlapping intervals that share the same chrom + psCN.
    We exclude any samples found in any of the exclude_sample_files.

    Final columns:
        chrom, start, end, locus, psCN, count, samples

    - 'locus' will be a semicolon-joined string of all distinct locus fields merged.
    - 'count' is the number of unique samples in that merged interval.
    - 'samples' is a comma-delimited list of sample IDs.

    The output is sorted in ascending order by 'count'.

    Parameters
    ----------
    input_dir : str
        Directory containing *.res.samples.bed.gz files.

    sample_id_file : str, optional
        Path to a text file listing sample IDs of interest (one per line).
        If None, all encountered samples are included (unless excluded).

    exclude_sample_files : list of str, optional
        One or more text files listing sample IDs to exclude. If a sample
        appears in any of these files, it will be skipped entirely.

    gene_names : list of str, optional
        If provided, only keep rows whose locus matches at least one gene.
        - If partial_gene_match=True, we allow a substring match.
        - Otherwise, exact match is used.

    output_file : str, optional
        If provided, save the table to a TSV file. Otherwise, prints to stdout.

    partial_gene_match : bool, optional
        Whether to allow partial string matching for gene filtering.
        If True, any gene in gene_names that appears as a substring
        of locus is considered a match. Default=False (exact match).

    Returns
    -------
    pd.DataFrame
        A DataFrame with columns:
            chrom, start, end, locus, psCN, count, samples
        where psCN is a string exactly as in the file,
        and samples is a comma-delimited list of sample IDs that had that psCN,
        after merging overlapping intervals.
    """

    # 1) Optional "include" sample filtering
    if sample_id_file is not None:
        with open(sample_id_file, 'r') as f:
            sample_list = {line.strip() for line in f if line.strip()}
    else:
        sample_list = None  # means "no explicit include filter"

    # 2) Combine all exclude files into one set of excluded samples
    excluded_sample_list = set()
    if exclude_sample_files:
        for exclude_path in exclude_sample_files:
            with open(exclude_path, 'r') as xf:
                for line in xf:
                    line = line.strip()
                    if line:
                        excluded_sample_list.add(line)

    # 3) Optional gene filtering
    gene_set = set(gene_names) if gene_names else None

    # -------------------------------------------------------------------------
    # 4) Group intervals by (chrom, psCN).
    # -------------------------------------------------------------------------
    data_dict = defaultdict(list)

    # 5) Read *.res.samples.bed.gz
    pattern = os.path.join(input_dir, '*res.samples.bed.gz')
    for bed_gz in glob(pattern):
        with gzip.open(bed_gz, 'rt') as f_in:
            for line in f_in:
                # skip empty/header
                if not line.strip() or line.startswith('#'):
                    continue

                cols = line.strip().split('\t')
                if len(cols) < 13:
                    continue  # malformed

                chrom       = cols[0]
                start       = int(cols[1])
                end         = int(cols[2])
                locus       = cols[3]
                sample      = cols[4]
                psCN_filter = cols[8]
                psCN_str    = cols[9]  # Keep as string

                # a) Exclusion check
                if sample in excluded_sample_list:
                    continue

                # b) Inclusion check
                if sample_list is not None and sample not in sample_list:
                    continue

                # c) gene filter
                if gene_set is not None:
                    if partial_gene_match:
                        # keep row if ANY of the genes is substring of locus
                        if not any(g in locus for g in gene_set):
                            continue
                    else:
                        # exact match
                        if locus not in gene_set:
                            continue

                # d) optional psCN_filter == 'PASS' check:
                # if psCN_filter != 'PASS':
                #     continue

                # e) Add interval to data_dict
                data_dict[(chrom, psCN_str)].append({
                    "start": start,
                    "end": end,
                    "locus_set": {locus},
                    "samples": {sample}
                })

    # -------------------------------------------------------------------------
    # 6) Merge overlapping intervals for each (chrom, psCN).
    # -------------------------------------------------------------------------
    merged_rows = []

    for (chrom, psCN_value), intervals in data_dict.items():
        # Sort intervals by start
        intervals.sort(key=lambda x: x["start"])

        merged = []
        current = None

        for iv in intervals:
            if current is None:
                current = {
                    "start": iv["start"],
                    "end": iv["end"],
                    "locus_set": set(iv["locus_set"]),
                    "samples": set(iv["samples"])
                }
                continue

            # Check overlap
            if iv["start"] <= current["end"] and iv["end"] >= current["start"]:
                # Overlaps => merge
                current["end"] = max(current["end"], iv["end"])
                current["locus_set"].update(iv["locus_set"])
                current["samples"].update(iv["samples"])
            else:
                # No overlap => push current to merged list
                merged.append(current)
                current = {
                    "start": iv["start"],
                    "end": iv["end"],
                    "locus_set": set(iv["locus_set"]),
                    "samples": set(iv["samples"])
                }

        # Last one
        if current is not None:
            merged.append(current)

        for m in merged:
            combined_locus = ";".join(sorted(m["locus_set"]))
            sample_list_str = ",".join(sorted(m["samples"]))
            count_val = len(m["samples"])

            merged_rows.append({
                "chrom": chrom,
                "start": m["start"],
                "end": m["end"],
                "locus": combined_locus,
                "psCN": psCN_value,
                "count": count_val,
                "samples": sample_list_str
            })

    # 7) Build final DataFrame
    if not merged_rows:
        print("No data found. Returning empty DataFrame.")
        return pd.DataFrame(columns=["chrom","start","end","locus","psCN","count","samples"])

    df = pd.DataFrame(
        merged_rows,
        columns=["chrom","start","end","locus","psCN","count","samples"]
    )

    # 8) Sort by 'count' ascending
    df.sort_values("count", ascending=True, inplace=True)

    # 9) Output
    if output_file:
        df.to_csv(output_file, sep='\t', index=False)
    else:
        print(df.to_csv(sep='\t', index=False))

    return df


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(
        description=(
            "Build a table of psCN usage across merged overlapping intervals. Overlapping "
            "regions on the same chrom with the same psCN are combined. Optionally exclude "
            "or include certain samples."
        )
    )
    parser.add_argument(
        "-i", "--input_dir",
        required=True,
        help="Directory containing *.res.samples.bed.gz files."
    )
    parser.add_argument(
        "-s", "--sample_id_file",
        required=False,
        default=None,
        help="Path to a text file listing sample IDs of interest (one per line). "
             "If not provided, all samples are included (unless excluded)."
    )
    parser.add_argument(
        "-x", "--exclude_sample_file",
        required=False,
        nargs='+',   # <--- multiple files allowed
        default=None,
        help="One or more files listing sample IDs to exclude. Any sample in these files is skipped."
    )
    parser.add_argument(
        "-g", "--gene_name",
        nargs="+",
        default=None,
        help="One or more gene names to filter on."
    )
    parser.add_argument(
        "-o", "--output_file",
        required=False,
        default=None,
        help="Output file name for the final TSV table. If not provided, prints to stdout."
    )
    parser.add_argument(
        "--partial_match",
        action="store_true",
        help="Use substring matching for gene names. By default, exact match is used."
    )

    args = parser.parse_args()

    build_psCN_count_table(
        input_dir=args.input_dir,
        sample_id_file=args.sample_id_file,
        exclude_sample_files=args.exclude_sample_file,  # list of file paths
        gene_names=args.gene_name,
        output_file=args.output_file,
        partial_gene_match=args.partial_match
    )
