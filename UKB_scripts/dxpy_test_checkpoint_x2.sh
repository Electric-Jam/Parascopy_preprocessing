instance_type=mem2_ssd1_v2_x2

for batch in {1..4}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/CN_using_analysis/HearingLoss_White_batch${batch}_ordered
    destination=UKB_Parascopy:/500k_analysis/CN_using_analysis/HearingLoss_White_batch${batch}_ordered

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_test_checkpoint_x2.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.bed \
    -iin=UKB_Parascopy:/500k_analysis/ModelBuilding/model_updated.tar.gz \
    -icmd="bash dxfuse_test_checkpoint_x2.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.17.4_tag_dxpy.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=low \
    --name=cn_call_White_Case_batch${batch}_testx2 \
    --yes
done
