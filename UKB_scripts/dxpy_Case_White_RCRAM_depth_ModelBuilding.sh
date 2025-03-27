source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd2_v2_x2

dx mkdir -p UKB_Parascopy:/500k_analysis/ModelBuilding
destination=UKB_Parascopy:/500k_analysis/ModelBuilding

while IFS= read -r sample; do
    dx run swiss-army-knife \
        -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_ModelBuilding_RCRAM_depth.sh \
        -iin=UKB_Parascopy:/RCRAM_gen/run_reduce.py \
        -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa \
        -iin=UKB_Parascopy:/parascopy_input/OTOA_modified_files/hg38_otoa.fa.fai \
        -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.500_padded.bed \
        -icmd="bash dxfuse_ModelBuilding_RCRAM_depth.sh ${sample}" \
        -iimage_file=/docker_image/parascopy_1.17.4_tag_dxpy.tar.gz \
        --destination ${destination} \
        --instance-type ${instance_type} \
        --ignore-reuse \
        --name=RCRAM_depth_ModelBuilding_${sample} \
        --yes

done < /home/eup009/dnanexus/batch_files/CTL_White_eid_batch_1.txt
