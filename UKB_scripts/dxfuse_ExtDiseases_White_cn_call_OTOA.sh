mkdir cn_output
cp -r /mnt/project/500k_analysis/step1/White_batch_extdiseases${1}/RCRAM_loci/ .
# Running parascopy cn
parascopy cn \
    -I RCRAM_loci/sample_list.txt \
    -t hg38_otoa.bed.gz \
    -f hg38_otoa.fa \
    -R /mnt/project/RCRAM_gen/loci_list.bed \
    -d . \
    -o cn_output \
    --modify-ref /mnt/project/500k_analysis/modify_ref_sexchr.bed \
    -@ 36 \
    --vmr 1.2 \
    --regions-subset OTOA

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
    -p cn_output \
    -i RCRAM_loci/${file}::${id} \
    -f hg38_otoa.fa \
    -t hg38_otoa.bed.gz \
    --freebayes /app/freebayes/build/freebayes \
    -o call_output/${id}_call \
    --regions-subset OTOA \
    -@ 1 > "$LOG_FILE" 2>&1

    rm -rf call_output/${id}_call/loci
}

export -f run_parascopy_call

# Use xargs to parallelize the calls
cat /mnt/project/500k_analysis/step1/White_batch_extdiseases${1}/RCRAM_loci/sample_list.txt | \
while IFS=$'\t' read -r file id; do
    echo "$file $id $1"
done | xargs -n 3 -P $NUM_JOBS bash -c 'run_parascopy_call "$@"' _

# Merge the vcf files
find call_output -type f -name "variants.vcf.gz" -print0 | \
xargs -0 bcftools merge -O z -o merged_variants.vcf.gz
bcftools index merged_variants.vcf.gz

find call_output -type f -name "variants_pooled.vcf.gz" -print0 | \
xargs -0 bcftools merge --force-samples -O z -o merged_variants_pooled.vcf.gz
bcftools index merged_variants_pooled.vcf.gz


# Tar and compress the entire call_output directory
echo "Tarring and compressing the entire call_output directory..."
tar -czf call_output.tar.gz call_output

echo "Tarring and compressing the logs directory..."
tar -czf logs.tar.gz logs

echo "Tarring and compressing cn_output directory..."
tar -czf cn_output.tar.gz cn_output

# Remove the original call_output directory after tarring
echo "Removing the original call_output directory..."
rm -rf call_output
rm -rf logs
rm -rf cn_output
rm -rf RCRAM_loci

echo "Tarring completed, and the original call_output directory has been removed."