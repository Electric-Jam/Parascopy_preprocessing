mkdir cn_output
#Running parascopy cn
# parascopy cn \
#     -I /mnt/project/500k_analysis/step1/Case_White_batch${1}/RCRAM_loci/sample_list.txt \
#     -t hg38.bed.gz \
#     -f GRCh38_full_analysis_set_plus_decoy_hla.fa \
#     -R /mnt/project/RCRAM_gen/loci_list.bed \
#     -d . \
#     -o cn_output \
#     --modify-ref /mnt/project/500k_analysis/modify_ref_sexchr.bed \
#     -@ 36 \
#     --run-vmr \
#     --threshold-value 1.2

cp  -r /mnt/project/500k_analysis/step2/Case_White_batch${1}/cn_output .
cp  -r /mnt/project/500k_analysis/step1/Case_White_batch${1}/RCRAM_loci/ .

mkdir call_output
parascopy call \
    -p cn_output \
    -I RCRAM_loci/sample_list.txt \
    -f GRCh38_full_analysis_set_plus_decoy_hla.fa \
    -t hg38.bed.gz \
    --regions-subset HYDIN_1 ABCC6 HYDIN_2 CEP170 SRGAP2_1 HYDIN_3 GTF2I ANAPC1 OCLN OTOA \
    --freebayes /app/freebayes/build/freebayes \
    -o call_output \
    -@ 1

rm -r cn_output
rm -r RCRAM_loci

# while IFS=$'\t' read -r file id
# do
    
#     echo running parascopy call for $file
#     echo sample id is $id
#     mkdir -p call_output/${id}_call

#     cp -v /mnt/project/500k_analysis/step1/Case_White_batch${1}/RCRAM_loci/${file} .
#     cp -v /mnt/project/500k_analysis/step1/Case_White_batch${1}/RCRAM_loci/${file}.crai .


#     parascopy call \
#     -p /mnt/project/500k_analysis/step1/Case_White_batch${1}/cn_res/cn_output \
#     -i ${file}::${id} \
#     -f GRCh38_full_analysis_set_plus_decoy_hla.fa \
#     -t hg38.bed.gz \
#     --freebayes /app/freebayes/build/freebayes \
#     -o call_output \
#     -@ 36

#     rm ${file}
#     rm ${file}.crai

# done < /mnt/project/500k_analysis/step1/Case_White_batch${1}/RCRAM_loci/sample_list.txt

