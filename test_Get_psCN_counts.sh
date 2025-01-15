python3 /home/eup009/parascopy_preprocessing/Get_psCN_counts.py \
    --input_dir /home/eup009/dnanexus/500k_analysis/tmp/HearingLoss_batch3/cn_output \
    -g STRC OTOA \
    --output /home/eup009/dnanexus/500k_analysis/tmp/test_psCN_counts_case.txt

python3 /home/eup009/parascopy_preprocessing/Get_psCN_counts.py \
    --input_dir /home/eup009/dnanexus/500k_analysis/res/ \
    -g STRC OTOA \
    -x /home/eup009/dnanexus/batch_files/early_H90_H91_batch_1.txt /home/eup009/dnanexus/batch_files/early_H90_H91_batch_2.txt /home/eup009/dnanexus/batch_files/early_H90_H91_batch_3.txt \

    --output /home/eup009/dnanexus/500k_analysis/tmp/test_psCN_counts_ctrl.txt

python3 /home/eup009/parascopy_preprocessing/Get_psCN_counts.py \
    --input_dir /home/eup009/dnanexus/500k_analysis/res/ \
    -g STRC OTOA \
    -x /home/eup009/dnanexus/batch_files/early_H90_H91_batch_1.txt /home/eup009/dnanexus/batch_files/early_H90_H91_batch_2.txt /home/eup009/dnanexus/batch_files/early_H90_H91_batch_3.txt \
    $(printf "/home/eup009/dnanexus/batch_files/White_hearingloss_batch_%d.txt " {1..44}) \
    --output /home/eup009/dnanexus/500k_analysis/tmp/test_psCN_counts_ctrl.txt
