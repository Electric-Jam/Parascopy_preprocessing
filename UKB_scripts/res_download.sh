for i in {1..42}
do
    # dx download --lightweight UKB_Parascopy:/500k_analysis/step2/Case_White_batch${i}/cn_output/psvs.vcf.gz -o \
    # /home/eup009/dnanexus/500k_analysis/res/Case_White_batch${i}_psvs.vcf.gz

    # dx download --lightweight UKB_Parascopy:/500k_analysis/step2/Case_White_batch${i}/cn_output/psvs.vcf.gz.tbi -o \
    # /home/eup009/dnanexus/500k_analysis/res/Case_White_batch${i}_psvs.vcf.gz.tbi

    # dx download -f --lightweight UKB_Parascopy:/500k_analysis/step2/Case_White_batch${i}/cn_output/res.matrix.bed.gz -o \
    # /home/eup009/dnanexus/500k_analysis/res/Case_White_batch${i}_res.matrix.bed.gz 

    # dx download -f --lightweight UKB_Parascopy:/500k_analysis/step2/Case_White_batch${i}/cn_output/res.matrix.bed.gz.tbi -o \
    # /home/eup009/dnanexus/500k_analysis/res/Case_White_batch${i}_res.matrix.bed.gz.tbi

    dx download -f --lightweight UKB_Parascopy:/500k_analysis/step2/Case_White_batch${i}/cn_output/res.samples.bed.gz -o \
    /home/eup009/dnanexus/500k_analysis/res/Case_White_batch${i}_res.samples.bed.gz &

    dx download -f --lightweight UKB_Parascopy:/500k_analysis/step2/Case_White_batch${i}/cn_output/res.samples.bed.gz.tbi -o \
    /home/eup009/dnanexus/500k_analysis/res/Case_White_batch${i}_res.samples.bed.gz.tbi &

    dx download -f --lightweight 


done

# ls *.vcf.gz > vcf_list.txt
# bcftools merge -l vcf_list.txt -o Case_White_psvs.vcf

