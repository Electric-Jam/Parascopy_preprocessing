source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd2_v2_x2

# for batch in {1..340}
for batch in {1..4}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/step1/HearingLoss_batch${batch}
    destination=UKB_Parascopy:/500k_analysis/step1/HearingLoss_batch${batch}

    dx run swiss-army-knife \
        -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_HearingLoss_White_RCRAM_depth.sh \
        -iin=UKB_Parascopy:/RCRAM_gen/run_reduce.py \
        -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
        -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
        -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.bed \
        -icmd="bash dxfuse_HearingLoss_White_RCRAM_depth.sh ${batch}" \
        -iimage_file=/docker_image/parascopy_1.17.1_tag.tar.gz \
        --destination ${destination} \
        --instance-type ${instance_type} \
        --ignore-reuse \
        --priority=normal \
        --name=RCRAM_depth_HearingLoss_White_batch${batch} \
        --yes
done