batch_file=/mnt/project/batch_files/Case_White_eid_batch_${1}.txt
mkdir RCRAM_loci
while IFS= read -r sample; do
    idx="${sample:0:2}"

    # Check if the sample has WGS data
    if [ -f "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram" ]; then
        echo "${sample} File exists"

    # Copy the cram file and its index
        cp -v "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram" .
        cp -v "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram.crai" .

        echo "copy completed for ${sample}_24048_0_0.dragen.cram"

    # Run depth for each sample
        parascopy depth \
            -i ${sample}_24048_0_0.dragen.cram::${sample} \
            -g hg38 \
            -f GRCh38_full_analysis_set_plus_decoy_hla.fa \
            -o ${sample}_depth \
            -@ 2

    #Generate reduced cram file for the loci
        python run_reduce.py \
            -i ${sample}_24048_0_0.dragen.cram \
            -o RCRAM_loci \
            -f GRCh38_full_analysis_set_plus_decoy_hla.fa \
            -r loci.and.hom.regions.hg38.bed \
            -@ 2

    #remove the original cram file
        rm ${sample}_24048_0_0.dragen.cram
        rm ${sample}_24048_0_0.dragen.cram.crai

     
    else
        echo "${sample} File does not exist"
    fi

done < $batch_file


#Merging the depth files
first_file=true
while IFS= read -r sample; do
    idx="${sample:0:2}"
    if [ -f "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram" ]; then
        echo "${sample} File exists"
        if $first_file; then
            # For the first file, include the header and data
            cat "${sample}_depth/depth.csv" > depth.csv
            echo -e "${sample}_24048_0_0.dragen.reduced.cram\t${sample}" > sample_list.txt
            first_file=false
        else
            # For the subsequent files, skip the header, include only data
            grep -v '^#' "${sample}_depth/depth.csv" | tail -n +2 >> depth.csv
            echo -e "${sample}_24048_0_0.dragen.reduced.cram\t${sample}" >> sample_list.txt
        fi
    else
        echo "${sample} File does not exist"
    fi
done < $batch_file
mv sample_list.txt RCRAM_loci/sample_list.txt


