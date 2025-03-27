mkdir cn_output
cp -r /mnt/project/500k_analysis/test_ModelBuilding/RCRAM_loci .

#untar RCRAM_loci
# tar -xzf RCRAM_loci.tar.gz

#Running parascopy cn
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

# Define the number of parallel jobs
NUM_JOBS=36

echo "Tarring and compressing cn_output directory..."
tar -czf cn_output.tar.gz cn_output

# Remove the original call_output directory after tarring
echo "Removing the original call_output directory..."
rm -rf cn_output
rm -rf RCRAM_loci

echo "Tarring completed, and the original call_output directory has been removed."

