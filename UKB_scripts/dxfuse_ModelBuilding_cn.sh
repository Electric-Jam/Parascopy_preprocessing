batch_file=/mnt/project/batch_files/CTL_White_eid_batch_${1}.txt
mkdir cn_output
cp -r /mnt/project/500k_analysis/ModelBuilding/RCRAM .
cp -r /mnt/project/500k_analysis/ModelBuilding/depth .


first_file=true
while IFS= read -r sample; do
    idx="${sample:0:2}"
    if [ -f "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram" ]; then
        echo "${sample} File exists"
        if $first_file; then
            # For the first file, include the header and data
            cat "depth/${sample}_depth.csv" > depth.csv
            echo -e "${sample}_24048_0_0_.dragen.reduced.cram\t${sample}" > sample_list.txt
            first_file=false
        else
            # For the subsequent files, skip the header, include only data
            grep -v '^#' "depth/${sample}_depth.csv" | tail -n +2 >> depth.csv
            echo -e "${sample}_24048_0_0_.dragen.reduced.cram\t${sample}" >> sample_list.txt
        fi
    else
        echo "${sample} File does not exist"
    fi
done < $batch_file
mv sample_list.txt RCRAM/sample_list.txt


#Running parascopy cn
parascopy cn \
    -I RCRAM/sample_list.txt \
    -t hg38_otoa.bed.gz \
    -f hg38_otoa.fa \
    -R /mnt/project/RCRAM_gen/loci_list_added.bed \
    -d . \
    -o cn_output \
    --modify-ref /mnt/project/500k_analysis/modify_ref_sexchr.bed \
    --clean p \
    -@ 36 \
    --vmr 1.2 \

# Define the number of parallel jobs
NUM_JOBS=36

echo "Tarring and compressing cn_output directory..."
tar -czf cn_output.tar.gz cn_output

# Remove the original call_output directory after tarring
echo "Removing the original call_output directory..."
rm -rf cn_output
rm -rf RCRAM
rm -rf depth

echo "Tarring completed, and the original call_output directory has been removed."

