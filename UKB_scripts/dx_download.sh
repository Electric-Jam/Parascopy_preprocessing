for batch in {1..42}
do
    destination=/home/eup009/dnanexus/500k_analysis/CN_using_res/Case_White_batch${batch}
    mkdir -p ${destination}
    cd ${destination}

    batch_file="/home/eup009/dnanexus/batch_files/Case_White_eid_batch_${batch}.txt"
    
    while IFS= read -r sample; do

    # check if the folder already exists if exists, skip
    if [ ! -d "${destination}/Case_White_batch${batch}/${sample}" ]; then
        echo "Downloading ${sample} from Case_White_batch${batch}"
        dx download -r --lightweight UKB_Parascopy:/500k_analysis/CN_using_analysis/Case_White_batch${batch}/${sample} -o ${destination}/Case_White_batch${batch}/${sample} &
    else
        echo "Folder ${sample} already exists in Case_White_batch${batch}"
    fi
    done < "${batch_file}"
    wait
done