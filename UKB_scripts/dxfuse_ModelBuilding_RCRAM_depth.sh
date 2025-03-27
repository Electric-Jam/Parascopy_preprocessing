sample=${1}
idx="${sample:0:2}"

# Check if the sample has WGS data
if [ -f "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram" ]; then
    echo "${sample} File exists"

# Copy the cram file and its index
    cp -v "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram" .
    cp -v "/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram.crai" .

    echo "copy completed for ${sample}_24048_0_0.dragen.cram"

# Run depth for each sample
    parascopy depth \
        -i ${sample}_24048_0_0.dragen.cram::${sample} \
        -g hg38 \
        -f hg38_otoa.fa \
        -o ${sample}_depth \
        -@ 2

#Generate reduced cram file for the loci
    python run_reduce.py \
        -i ${sample}_24048_0_0.dragen.cram \
        -o . \
        -f hg38_otoa.fa \
        -r loci.and.hom.regions.hg38.500_padded.bed \
        -@ 2

#remove the original cram file
    rm ${sample}_24048_0_0.dragen.cram
    rm ${sample}_24048_0_0.dragen.cram.crai

    
else
    echo "${sample} File does not exist"
fi

mv ${sample}_depth/depth.csv ${sample}_depth.csv

# upload the depth output and reduced cram file
dx login --token 8KULUzaOnMAz3gXnTesN43GVrC2XuIWb --noprojects
dx mkdir -p UKB_Parascopy:/500k_analysis/ModelBuilding/RCRAM
dx mkdir -p UKB_Parascopy:/500k_analysis/ModelBuilding/depth

dx upload ${sample}_depth.csv --path UKB_Parascopy:/500k_analysis/ModelBuilding/depth/${sample}_depth.csv
dx upload ${sample}_24048_0_0.dragen.reduced.cram --path UKB_Parascopy:/500k_analysis/ModelBuilding/RCRAM/${sample}_24048_0_0_.dragen.reduced.cram
dx upload ${sample}_24048_0_0.dragen.reduced.cram.crai --path UKB_Parascopy:/500k_analysis/ModelBuilding/RCRAM/${sample}_24048_0_0_.dragen.reduced.cram.crai

rm -rf ./*




