source ~/anaconda3/bin/activate dxpy
instance_type=mem1_ssd2_v2_x2

for batch in {1..42}
do
    dx mkdir -p UKB_Parascopy:/500k_analysis/step1/Case_White_batch${batch}
    destination=UKB_Parascopy:/500k_analysis/step1/Case_White_batch${batch}

    dx run swiss-army-knife \
        -iin=UKB_Parascopy:/500k_analysis/scripts/dxfuse_Case_White_RCRAM_depth.sh \
        -iin=UKB_Parascopy:/RCRAM_gen/run_reduce.py \
        -iin=UKB_Parascopy:/RCRAM_gen/GRCh38_full_analysis_set_plus_decoy_hla.fa \
        -iin=UKB_Parascopy:/RCRAM_gen/loci.and.hom.regions.hg38.bed \
        -icmd="bash dxfuse_Case_White_RCRAM_depth.sh ${batch}" \
        -iimage_file=/docker_image/parascopy_vmr.tar.gz \
        --destination ${destination} \
        --instance-type ${instance_type} \
        --ignore-reuse \
        --name=RCRAM_depth_Case_White_batch${batch} \
        --yes
done