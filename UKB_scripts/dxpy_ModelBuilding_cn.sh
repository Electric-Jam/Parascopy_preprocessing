source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd1_v2_x36

batch=1

dx mkdir -p UKB_Parascopy:/500k_analysis/ModelBuilding
destination=UKB_Parascopy:/500k_analysis/ModelBuilding


dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_ModelBuilding_cn.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -icmd="bash dxfuse_ModelBuilding_cn.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.17.4_tag_dxpy.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=high \
    --cost-limit 15 \
    --name=cn_Case_White_batch${batch}_ModelBuilding \
    --yes

