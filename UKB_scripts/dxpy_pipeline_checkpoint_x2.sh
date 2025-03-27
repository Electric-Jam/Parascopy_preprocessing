instance_type=mem2_ssd1_v2_x2

for batch in {1..42}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/CN_using_analysis/Case_White_batch${batch}
    destination=UKB_Parascopy:/500k_analysis/CN_using_analysis/Case_White_batch${batch}

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_pipeline_checkpoint_x2.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.bed \
    -iin=UKB_Parascopy:/500k_analysis/ModelBuilding/model_updated.tar.gz \
    -icmd="bash dxfuse_pipeline_checkpoint_x2.sh ${batch} 500k_analysis/CN_using_analysis/Case_White_batch${batch} /mnt/project/batch_files/Case_White_eid_batch_${batch}.txt" \
    -iimage_file=/docker_image/parascopy_1.17.4_tag_dxpy.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=low \
    --name=cn_call_White_Case_batch${batch}_testx2 \
    --yes
done


for batch in {1..6}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/CN_using_analysis/White_extdisease_batch_${batch}
    destination=UKB_Parascopy:/500k_analysis/CN_using_analysis/White_extdisease_batch_${batch}

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_pipeline_checkpoint_x2.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.bed \
    -iin=UKB_Parascopy:/500k_analysis/ModelBuilding/model_updated.tar.gz \
    -icmd="bash dxfuse_pipeline_checkpoint_x2.sh ${batch} 500k_analysis/CN_using_analysis/White_extdisease_batch_${batch} /mnt/project/batch_files/White_extdisease_batch_${batch}.txt" \
    -iimage_file=/docker_image/parascopy_1.17.4_tag_dxpy.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=low \
    --name=cn_call_White_extdisease${batch}_testx2 \
    --yes
done


for batch in {1..150}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/CN_using_analysis/CTL_White_eid_batch_${batch}
    destination=UKB_Parascopy:/500k_analysis/CN_using_analysis/CTL_White_eid_batch_${batch}

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_pipeline_checkpoint_x2.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.bed \
    -iin=UKB_Parascopy:/500k_analysis/ModelBuilding/model_updated.tar.gz \
    -icmd="bash dxfuse_pipeline_checkpoint_x2.sh ${batch} 500k_analysis/CN_using_analysis/CTL_White_eid_batch_${batch} /mnt/project/batch_files/CTL_White_eid_batch_${batch}.txt" \
    -iimage_file=/docker_image/parascopy_1.17.4_tag_dxpy.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=low \
    --name=cn_call_CTL_White_eid_batch_${batch}_testx2 \
    --yes
done