source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd1_v2_x36

for batch in {1..6}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/step2/White_batch_extdiseases${batch}
    destination=UKB_Parascopy:/500k_analysis/step2/White_batch_extdiseases${batch}

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_ExtDiseases_White_cn_call.sh \
    -iin=UKB_Parascopy:/RCRAM_gen/GRCh38_full_analysis_set_plus_decoy_hla.fa \
    -iin=UKB_Parascopy:/parascopy_input/hg38.fa \
    -iin=UKB_Parascopy:/parascopy_input/hg38.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/hg38.md5 \
    -iin=UKB_Parascopy:/parascopy_input/hg38.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/hg38.bed.gz.tbi \
    -iin=UKB_Parascopy:/500k_analysis/step1/White_batch_extdiseases${batch}/depth.csv \
    -icmd="bash dxfuse_ExtDiseases_White_cn_call.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.16.2_tag.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --name=cn_White_batch_extdiseases${batch} \
    --yes
done

# -iimage_file=/docker_image/parascopy_1.16.0_tag.tar.gz \