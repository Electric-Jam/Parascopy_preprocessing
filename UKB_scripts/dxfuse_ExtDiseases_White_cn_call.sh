# mkdir cn_output
# # Running parascopy cn
# parascopy cn \
#     -I /mnt/project/500k_analysis/step1/White_batch_extdiseases${1}/RCRAM_loci/sample_list.txt \
#     -t hg38.bed.gz \
#     -f GRCh38_full_analysis_set_plus_decoy_hla.fa \
#     -R /mnt/project/RCRAM_gen/loci_list.bed \
#     -d . \
#     -o cn_output \
#     --modify-ref /mnt/project/500k_analysis/modify_ref_sexchr.bed \
#     -@ 36 \
#     --run-vmr \
#     --threshold-value 1.2



#!/bin/bash

# Define the number of parallel jobs
NUM_JOBS=36

# Function to run the parascopy call
run_parascopy_call() {
    file=$1
    id=$2
    batch=$3
    
    echo "Running parascopy call for ${file}"
    echo "Sample ID is ${id}"
    mkdir -p call_output/${id}_call

    cp -v /mnt/project/500k_analysis/step1/White_batch_extdiseases${batch}/RCRAM_loci/${file} .
    cp -v /mnt/project/500k_analysis/step1/White_batch_extdiseases${batch}/RCRAM_loci/${file}.crai .

    parascopy call \
    -p /mnt/project/500k_analysis/step2/White_batch_extdiseases${batch}/cn_output \
    -i ${file}::${id} \
    -f GRCh38_full_analysis_set_plus_decoy_hla.fa \
    -t hg38.bed.gz \
    --freebayes /app/freebayes/build/freebayes \
    -o call_output/${id}_call \
    -@ 1

    rm ${file}
    rm ${file}.crai
    rm -rf call_output/${id}_call/loci
}

export -f run_parascopy_call

# Use xargs to parallelize the calls
cat /mnt/project/500k_analysis/step1/White_batch_extdiseases${1}/RCRAM_loci/sample_list.txt | \
while IFS=$'\t' read -r file id; do
    echo "$file $id $1"
done | xargs -n 3 -P $NUM_JOBS bash -c 'run_parascopy_call "$@"' _


# Tar and compress the entire call_output directory
echo "Tarring and compressing the entire call_output directory..."
tar -czf call_output.tar.gz call_output

# Remove the original call_output directory after tarring
echo "Removing the original call_output directory..."
rm -rf call_output

echo "Tarring completed, and the original call_output directory has been removed."

