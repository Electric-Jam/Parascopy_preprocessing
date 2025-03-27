instance_type=mem1_ssd1_v2_x4

for batch in 4
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/CheckPoint/test/HearingLoss_White_batch${batch}
    destination=UKB_Parascopy:/500k_analysis/CheckPoint/test/HearingLoss_White_batch${batch}

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_test_checkpoint.sh \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz \
    -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.bed.gz.tbi \
    -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.bed \
    -iin=UKB_Parascopy:/parascopy_input/model_test.tar.gz \
    -icmd="bash dxfuse_test_checkpoint.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.17.2_tag_dxpy.tar.gz \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=low \
    --name=cn_call_White_Case_batch${batch}_testx4 \
    --yes
done
