source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd1_v2_x36

for batch in {1..42}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/step2/Case_White_batch${batch}/OTOA
    destination=UKB_Parascopy:/500k_analysis/step2/Case_White_batch${batch}/OTOA

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_Case_White_cn_call_OTOA.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -iin=UKB_Parascopy:/500k_analysis/step1/Case_White_batch${batch}/depth.csv \
    -icmd="bash dxfuse_Case_White_cn_call_OTOA.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.17.1_tag.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=normal \
    --name=cn_call_White_Case_batch${batch} \
    --yes
done

