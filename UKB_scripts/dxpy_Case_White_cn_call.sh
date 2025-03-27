source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd1_v2_x36

for batch in {1..42}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/step2/Case_White_batch${batch}
    destination=UKB_Parascopy:/500k_analysis/step2/Case_White_batch${batch}

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_Case_White_cn_call.sh \
    -iin=UKB_Parascopy:/RCRAM_gen/GRCh38_full_analysis_set_plus_decoy_hla.fa \
    -iin=UKB_Parascopy:/parascopy_input/hg38.fa \
    -iin=UKB_Parascopy:/parascopy_input/hg38.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/hg38.md5 \
    -iin=UKB_Parascopy:/parascopy_input/hg38.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/hg38.bed.gz.tbi \
    -iin=UKB_Parascopy:/500k_analysis/step1/Case_White_batch${batch}/depth.csv \
    -icmd="bash dxfuse_Case_White_cn_call.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.17.0_tag.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --name=cn_call_White_Case_batch${batch} \
    --yes
done

