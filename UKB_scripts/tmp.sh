for i in {1..44}
do
    dx rm -rf UKB_Parascopy:/500k_analysis/step1/Case_White_batch${i}/RCRAM_loci
done

for i in {1..6}
do
    dx rm -rf UKB_Parascopy:/500k_analysis/step1/White_batch_extdiseases${i}/RCRAM_loci
done