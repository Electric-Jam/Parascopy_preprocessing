python3 /home/eup009/parascopy_preprocessing/GetPhenoEnrichment.py \
    --icd_data /home/eup009/dnanexus/ICD_primary.tsv \
    --sample_ids_file /home/eup009/dnanexus/batch_files/early_H90_H91_batch_1.txt \
    /home/eup009/dnanexus/batch_files/early_H90_H91_batch_2.txt \
    /home/eup009/dnanexus/batch_files/early_H90_H91_batch_3.txt \
    /home/eup009/dnanexus/batch_files/early_H90_H91_batch_4.txt \
    --output /home/eup009/parascopy_preprocessing/test_EnrichmentOut.txt

    

python3 /home/eup009/parascopy_preprocessing/GetPhenoEnrichment.py \
    --icd_data /home/eup009/dnanexus/ICD_primary.tsv \
    --sample_ids_list 5067852 2197621 \
    --output /home/eup009/parascopy_preprocessing/test_EnrichmentOut.txt

python3 /home/eup009/parascopy_preprocessing/GetPhenoEnrichment.py \
    --icd_data /home/eup009/dnanexus/ICD_primary.tsv \
    --sample_ids_list 1030982 4050564 4206674 \
    --output /home/eup009/parascopy_preprocessing/test_EnrichmentOut.txt