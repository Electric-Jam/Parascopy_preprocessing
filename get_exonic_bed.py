from pyensembl import EnsemblRelease
import pandas as pd

gene_list = ['HYDIN', 'ABCC6', 'CEP170', 'SRGAP2', 'GTF2I', 'ANAPC1', 'OCLN', 'OTOA', 'STRC', 'NCF1', 'CR1', 'CFHR1/CFHR3', 'RHCE', 'PDPK1', 'SUZ12', 'PROS1', 'SMN1', 'FCGR2A', 'PMS2', 'LPA', 'ACSM2A', 'BMP8A', 'OPN1LW', 'FCGR1A', 'DDX11', 'METTL2B', 'C4A', 'CES1', 'CCZ1', 'CD8B', 'CRYBB2', 'RABL2A', 'FLG', 'PRDM9', 'GSTM1', 'IKBKG', 'CFC1', 'AKR1C2', 'CYP4A11', 'GBA', 'CLCNKA/CLCNKB', 'CEL', 'TTN', 'CD177', 'NEB', 'HBA1/HBA2', 'SULT1A4', 'ZNF419', 'HP', 'SBDS', 'PIK3CA', 'CYP11B1', 'SULT1A1', 'KRT81', 'CTRB1', 'SAA1', 'KRT6C', 'IFNL2', 'MSTO1', 'SFTPA1/SFTPA2', 'CSH1', 'SIGLEC14', 'RAB40AL', 'TLR1/TLR6']
exon_bed = pd.DataFrame(columns=['contig', 'start', 'end'])

# Get a single exonic bed file for the genes in gene_list
ensembl = EnsemblRelease(111)
for gene in ensembl.genes():
    if gene.gene_name in gene_list:
        exons = gene.exons
        for exon in exons:
            exon_bed = exon_bed.append({'contig': 'chr' + exon.contig, 'start': exon.start, 'end': exon.end}, ignore_index=True)

exon_bed.to_csv('exonic_bed.bed', index=False, sep='\t', header=False)