source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd1_v2_x36

batch=1

dx mkdir -p UKB_Parascopy:/500k_analysis/test_ModelBuilding
destination=UKB_Parascopy:/500k_analysis/test_ModelBuilding


dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_Case_White_cn_ModelBuilding.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -iin=UKB_Parascopy:/500k_analysis/test_ModelBuilding/depth.csv \
    -icmd="bash dxfuse_Case_White_cn_ModelBuilding.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.17.2_tag_dxpy.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=low \
    --cost-limit 15 \
    --name=cn_Case_White_batch${batch}_ModelBuilding \
    --yes

