import pandas as pd
import gzip
import argparse
import os
from collections import Counter
from collections import defaultdict
from pyensembl import EnsemblRelease

def read_gz_file(file_path):
    try:
        with gzip.open(file_path, 'rt') as file:
            lines = file.readlines()
            
            # Extracting metadata and column names
            metadata = []
            data_lines = []
            for line in lines:
                if line.startswith("##"):
                    metadata.append(line.strip())
                elif line.startswith("#"):
                    column_names = line.strip().split()  # Skipping the initial '#'
                else:
                    data_lines.append(line.strip().split())

            # Creating DataFrame
            df = pd.DataFrame(data_lines, columns=column_names)
            
            return metadata, df

    except Exception as e:
        print(f"An error occurred: {e}")
        return None, None

def create_genotype_agCN(data_frame):
    # Pivoting the table to create genotype matrix with agCN values
    genotype_matrix = data_frame.pivot(index='variant', columns='sample', values='agCN')
    print(f"\nGenotype Matrix agCN:")
    print(genotype_matrix)

    return genotype_matrix

def create_genotype_psCN(data_frame, isDuplication = None, isDeletion = None, isExonic = None, exon_dic_start = None, exon_dic_end = None):
    # Convert psCN values to tuples of integers, handle '?' values
    data_frame['psCN_tuple'] = data_frame['psCN'].apply(lambda x: tuple((int(y) if y != '?' else None) for y in x.split(',')))
    
    # Hardcoding majority_psCN as (2, 2)
    ref_psCN = (2, 2)
    
    def map_psCN(value, ref_value, isDuplication=isDuplication, isDeletion=isDeletion):
        if None in value:
            return None
        if isDuplication:
            deviations = max(0, value[0] - ref_value[0])
        elif isDeletion:
            deviations = max(0, ref_value[0] - value[0])
        return deviations
    
    data_frame['psCN_mapped'] = data_frame.apply(lambda row: map_psCN(row['psCN_tuple'], ref_psCN), axis=1)
    
    # Pivoting the table to create genotype matrix with psCN_mapped values
    genotype_matrix = data_frame.pivot(index='variant', columns='sample', values='psCN_mapped')

    # Remove rows where all values are NaN
    genotype_matrix = genotype_matrix.dropna(how='all')

    # Convert all numeric values to integers while leaving NaN values unchanged
    genotype_matrix = genotype_matrix.apply(pd.to_numeric, errors='coerce').astype('Int64')

    #filtering out non-exonic intervals
    if isExonic:
        print(f"\nFiltering out non-exonic intervals for psCN")
        print(f"\nNumber of variants before filtering: {len(genotype_matrix.index)}")
        exonic_idx = []
        for i in range(len(genotype_matrix.index)):
            chrom, start, end = genotype_matrix.index[i].split('_') ; chrom = chrom.replace('chr', '')

            for exon_start, exon_end in zip(exon_dic_start[chrom], exon_dic_end[chrom]):
                if int(start) >= exon_start and int(start) <= exon_end:
                    exonic_idx.append(i)
                    break
                if int(end) >= exon_start and int(end) <= exon_end:
                    exonic_idx.append(i)
                    break
                if int(start) <= exon_start and int(end) >= exon_end:
                    exonic_idx.append(i)
                    break          

        exonic_idx = list(set(exonic_idx))
        genotype_matrix = genotype_matrix.iloc[exonic_idx]
        print(f"\nNumber of variants after filtering: {len(genotype_matrix.index)}")

        # print(f"\nGenotype Matrix psCN:")
        # print(genotype_matrix)

    return genotype_matrix

def collapse_by_gene(genotype_matrix, data_frame):    
    # Extract only 'locus' and 'variant' columns
    data_frame = data_frame[['locus', 'variant']]

    # Remove duplicates that have the same 'locus' and 'variant'
    gene_genotype_dict = data_frame.drop_duplicates()

    # re-index the gene_genotype_dict
    gene_genotype_dict = gene_genotype_dict.reset_index(drop=True)

    # order gene_genotype_dict by locus
    gene_genotype_dict = gene_genotype_dict.sort_values(by='locus')

    # iterate through each unique values of locus from gene_genotype_dict
    res_df = pd.DataFrame()
    for locus in gene_genotype_dict['locus'].unique():
        # get the variants that are associated with the locus
        locus_variants = gene_genotype_dict[gene_genotype_dict['locus'] == locus]['variant']

        # get the subset of genotype_matrix that has the variant column in locus_variants
        locus_genotype_matrix = genotype_matrix[genotype_matrix.index.isin(locus_variants)]
        locus_genotype_matrix = locus_genotype_matrix.max(axis=0, skipna=True)
        
        # add the locus_genotype_matrix to res_df as a single row
        # the variant column will be the locus name
        locus_genotype_matrix = locus_genotype_matrix.to_frame().T
        locus_genotype_matrix.index = [locus]
        res_df = pd.concat([res_df, locus_genotype_matrix])
        
    return res_df

def str2bool(v):
    if isinstance(v, bool):
        return v
    if v.lower() in ('yes', 'true', 't', 'y', '1', 'True', 'TRUE'):
        return True
    elif v.lower() in ('no', 'false', 'f', 'n', '0', 'False', 'FALSE'):
        return False
    else:
        raise argparse.ArgumentTypeError('Boolean value expected.')    

def main():
    parser = argparse.ArgumentParser(description='Read gzipped files from a directory and extract data.')
    parser.add_argument('--directory', type=str, help='Path to the directory containing gzipped files', required=True)
    parser.add_argument('--isExonic', type=str2bool, help='Mask for loci filtration. if  set to true, only exonic intervals are used for genotyping', required=True)
    parser.add_argument('--isDuplication', type=str2bool, help='Mask for loci filtration. if  set to true, only duplication intervals are used for genotyping', required=True)
    parser.add_argument('--isDeletion', type=str2bool, help='Mask for loci filtration. if  set to true, only deletion intervals are used for genotyping', required=True)
    parser.add_argument('--output', type=str, help='Path to the output CSV file', required=True)
    
    args = parser.parse_args()
    directory = args.directory
    isExonic = args.isExonic
    isDuplication = args.isDuplication
    isDeletion = args.isDeletion
    out_path = args.output

    if isExonic:
        print(f"\nFetching exonic intervals...")
        ensembl = EnsemblRelease(111)
        exon_dic_start = defaultdict(list) ; exon_dic_end = defaultdict(list)
        for gene in ensembl.genes():
            for transcript in gene.transcripts:
                for exon in transcript.exons:
                    exon_dic_start[exon.contig].append(exon.start)
                    exon_dic_end[exon.contig].append(exon.end)
    else:
         exon_dic_start = None
         exon_dic_end = None           
    
    df_loc_var_list = []
    genotype_matrices_agCN = []
    genotype_matrices_psCN_Dup = []
    genotype_matrices_psCN_Del = []

    print(f"\nReading files from {directory}")
    for file_name in sorted(os.listdir(directory)):
        if file_name.endswith('res.samples.bed.gz'):
            file_path = os.path.join(directory, file_name)
            metadata, data_frame = read_gz_file(file_path)

            if not data_frame.empty:
                print(f"\nData from {file_name}:")
                print(data_frame)

                data_frame['variant'] = data_frame.apply(lambda row: f"{row['#chrom']}_{row['start']}_{row['end']}", axis=1)

                genotype_matrix_agCN = create_genotype_agCN(data_frame)
                genotype_matrices_agCN.append(genotype_matrix_agCN)
                
                if isDuplication:
                    genotype_matrix_psCN_Dup = create_genotype_psCN(data_frame, isDuplication = isDuplication, isExonic = isExonic, exon_dic_start = exon_dic_start, exon_dic_end = exon_dic_end)
                    genotype_matrix_psCN_Dup = collapse_by_gene(genotype_matrix_psCN_Dup, data_frame)
                    print(f"\nGenotype Matrix psCN Duplication:")
                    print(genotype_matrix_psCN_Dup)
                    genotype_matrices_psCN_Dup.append(genotype_matrix_psCN_Dup)

                if isDeletion:
                    genotype_matrix_psCN_Del = create_genotype_psCN(data_frame,  isDeletion = isDeletion, isExonic = isExonic, exon_dic_start = exon_dic_start, exon_dic_end = exon_dic_end)
                    genotype_matrix_psCN_Del = collapse_by_gene(genotype_matrix_psCN_Del, data_frame)
                    print(f"\nGenotype Matrix psCN Deletion:")
                    print(genotype_matrix_psCN_Del)
                    genotype_matrices_psCN_Del.append(genotype_matrix_psCN_Del)


                df_loc_var_list.append(data_frame[['locus', 'variant']])

    df_loc_var = pd.concat(df_loc_var_list)
    df_loc_var = df_loc_var.drop_duplicates()
    
    if genotype_matrices_agCN:
        combined_agCN = pd.concat(genotype_matrices_agCN, axis=1)

        # left join genotype_matrix on data_frame to add 'locus' column
        combined_agCN = combined_agCN.join(df_loc_var.set_index('variant'), on='variant')

        # Bring the locus column to the front
        cols = combined_agCN.columns.tolist()
        cols = cols[-1:] + cols[:-1]
        combined_agCN = combined_agCN[cols]

        combined_agCN.to_csv(f"{out_path}_agCN.tsv", sep='\t')
        print(f"\nCombined Genotype Matrix agCN:")
        print(combined_agCN)

        #filtering out non-exonic intervals
        if isExonic:
            print(f"\nFiltering out non-exonic intervals")
            exonic_idx = []
            for i in range(len(combined_agCN.index)):
                chrom, start, end = combined_agCN.index[i].split('_') ; chrom = chrom.replace('chr', '')

                for exon_start, exon_end in zip(exon_dic_start[chrom], exon_dic_end[chrom]):
                    if int(start) >= exon_start and int(start) <= exon_end:
                        exonic_idx.append(i)
                        break
                    if int(end) >= exon_start and int(end) <= exon_end:
                        exonic_idx.append(i)
                        break
                    if int(start) <= exon_start and int(end) >= exon_end:
                        exonic_idx.append(i)
                        break

            exonic_idx = list(set(exonic_idx))
            combined_agCN = combined_agCN.iloc[exonic_idx]
            print(f"\nCombined Genotype Matrix agCN after filtering out non-exonic intervals:")
            print(combined_agCN)
            
    
    if genotype_matrices_psCN_Dup:
        combined_psCN_Dup = pd.concat(genotype_matrices_psCN_Dup, axis=1)
        combined_psCN_Dup.to_csv(f"{out_path}_psCN_Dup.tsv", sep='\t')
        print(f"\nCombined Genotype Matrix psCN Duplication:")
        print(combined_psCN_Dup)

    if genotype_matrices_psCN_Del:
        combined_psCN_Del = pd.concat(genotype_matrices_psCN_Del, axis=1)
        combined_psCN_Del.to_csv(f"{out_path}_psCN_Del.tsv", sep='\t')
        print(f"\nCombined Genotype Matrix psCN Deletion:")
        print(combined_psCN_Del)

if __name__ == "__main__":
    main()
