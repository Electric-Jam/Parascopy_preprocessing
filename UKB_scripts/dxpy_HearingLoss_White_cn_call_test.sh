source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd1_v2_x2

batch=1
    dx mkdir -p UKB_Parascopy:/500k_analysis/step2/HearingLoss_batch${batch}
    destination=UKB_Parascopy:/500k_analysis/step2/HearingLoss_batch${batch}

    #if the destination folder has the output, skip the run
    if dx ls ${destination}/merged_variants.vcf.gz | grep -q merged_variants.vcf.gz
    then
        echo "Output already exists for batch ${batch}. Skipping the run."
        continue
    fi

    dx run swiss-army-knife \
    -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_HearingLoss_White_cn_call_test.sh \
    -icmd="bash dxfuse_HearingLoss_White_cn_call_test.sh ${batch}" \
    -iimage_file=/docker_image/parascopy_1.17.2_tag_dxpy.tar.gz \
    -imount_inputs=true \
    --destination ${destination} \
    --instance-type ${instance_type} \
    --ignore-reuse \
    --priority=normal \
    --cost-limit 15 \
    --name=cn_call_HearingLoss_White_batch${batch}_test_cnusing \
    --yes
