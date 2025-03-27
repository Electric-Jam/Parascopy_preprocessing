#!/usr/bin/env bash
set -euo pipefail
dx login --token 8KULUzaOnMAz3gXnTesN43GVrC2XuIWb --noprojects
############################################
# Usage:
#   ./run_parascopy.sh <BATCH_INDEX>
#
# Example:
#   ./run_parascopy.sh 1
############################################

# 1) Parse input argument
BATCH_INDEX="${1}"

# 2) Define paths and filenames
batch_file="/mnt/project/batch_files/early_H90_H91_batch_${BATCH_INDEX}.txt"

# We store the local checkpoint in the current working directory (.)
checkpoint_file="checkpoint.txt"

# 3) Define the base DNAnexus destination folder for outputs
destination_base="project-Gg0YQJQJ0jGby8j2Q13JZQbQ:/500k_analysis/CN_using_analysis/HearingLoss_White_batch${BATCH_INDEX}_ordered"
destination_base_mnt="/mnt/project/500k_analysis/CN_using_analysis/HearingLoss_White_batch${BATCH_INDEX}_ordered"
dx mkdir -p "${destination_base}"

# Where to store the checkpoint file on DNAnexus
dx_checkpoint_path="${destination_base}/checkpoint.txt"

# 4) Unzip the model file if needed
echo "Unzipping model.tar.gz..."
tar -xzf model_updated.tar.gz

# 5) Number of threads to use
num_threads=2

# -----------------------------------------------------------------------------
# Function to check if the last sample in checkpoint.txt completed successfully
# (both the cn and call outputs).
# Returns:
#   0 if last sample is done,
#   1 if not done,
#   2 if checkpoint is empty or missing.
# -----------------------------------------------------------------------------
check_last_sample_completed() {
    echo "[INFO] Checking if last sample in checkpoint..."
    if [ ! -s "${checkpoint_file}" ]; then
        # checkpoint file is empty or doesn't exist
        echo "[INFO] Checkpoint file is empty or missing."
        return 2
    fi

    local last_sample
    last_sample="$(tail -n 1 "${checkpoint_file}")"

    # Adjust checks if your outputs differ in filenames
    if [ -f "${destination_base_mnt}/${last_sample}/${last_sample}_cn.tar.gz" ] && [ -f "${destination_base_mnt}/${last_sample}/${last_sample}_call.tar.gz" ]; then
        # The last sample in checkpoint has completed outputs
        echo "[INFO] Last sample in checkpoint is complete."
        return 0
    else
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Function to measure time for a step and log it to a file
# Usage: log_step_time "Step Name" "timing.log" command [args...]
# -----------------------------------------------------------------------------
log_step_time() {
    local step_name="$1"
    local log_file="$2"
    shift 2

    local start_time end_time elapsed

    # Capture time before
    start_time=$(date +%s)

    # Execute command
    "$@"

    # Capture time after
    end_time=$(date +%s)
    elapsed=$(( end_time - start_time ))

    # Log the elapsed time
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Step '${step_name}' took ${elapsed} seconds." >> "${log_file}"
}

# -----------------------------------------------------------------------------
# Function to upload files (or patterns) to DNAnexus
# -----------------------------------------------------------------------------
upload_to_dnanexus() {
    local pattern="$1"       # file pattern to upload
    local destination="$2"   # DNAnexus folder/path
    dx upload ${pattern} --destination "${destination}/${pattern}" --parents
}

upload_to_dnanexus_dir() {
    local pattern="$1"       # file pattern to upload
    local destination="$2"   # DNAnexus folder/path

    #tar the directory
    tar -czf ${pattern}.tar.gz ${pattern}
    dx upload ${pattern}.tar.gz --destination "${destination}/${pattern}.tar.gz" --parents
}

# -----------------------------------------------------------------------------
# Function to remove-and-reupload the checkpoint to DNAnexus
# (since we cannot overwrite in place).
# -----------------------------------------------------------------------------
upload_timelog() {
    local log_file="$1"
    local remote_path="$2"

    # Remove any old log at remote_path
    dx rm --all "${remote_path}/${log_file}" 2>/dev/null || true

    # Upload the new log
    dx upload "${log_file}" --destination "${remote_path}/${log_file}" --parents
}

upload_checkpoint() {
    local local_checkpoint="$1"
    local remote_path="$2"

    # Remove any old checkpoint at remote_path
    dx rm --all "${remote_path}/${local_checkpoint}" 2>/dev/null || true

    # Upload the new checkpoint
    dx upload "${local_checkpoint}" --destination "${remote_path}/${local_checkpoint}" --parents
}

# -----------------------------------------------------------------------------
# Pipeline: copy CRAM, run parascopy depth/cn/call, update checkpoint
# -----------------------------------------------------------------------------
run_parascopy_pipeline() {
    local sample="$1"
    local idx="${sample:0:2}"
    local timing_log="${sample}_timing.log"

    echo "Processing sample: ${sample}"
    > "${timing_log}"  # create/empty the timing log for this sample

    # DNAnexus subfolder for this sample
    local dx_dest="${destination_base}/${sample}"

    # 1) Check if the sample has WGS data
    local cram_path="/mnt/project/Bulk/DRAGEN WGS/Whole genome CRAM files (DRAGEN) [500k release]/${idx}/${sample}_24048_0_0.dragen.cram"
    local crai_path="${cram_path}.crai"

    if [ -f "${cram_path}" ]; then
        echo "[INFO] Found CRAM for sample ${sample}."

        # --- Copy CRAM + CRAI ---
        log_step_time "Copy CRAM" "${timing_log}" cp -v "${cram_path}" .
        log_step_time "Copy CRAI" "${timing_log}" cp -v "${crai_path}" .

        # --- parascopy depth ---
        log_step_time "parascopy depth" "${timing_log}" parascopy depth \
            -i "${sample}_24048_0_0.dragen.cram::${sample}" \
            -g hg38 \
            -f hg38_otoa.fa \
            -o "${sample}_depth" \
            -@ ${num_threads}
        # Upload depth outputs
        log_step_time "uplading parascopy depth output" "${timing_log}" upload_to_dnanexus_dir "${sample}_depth" "${dx_dest}"
        upload_timelog "${timing_log}" "${dx_dest}"

        # --- parascopy cn-using model ---
        log_step_time "parascopy cn-using" "${timing_log}" parascopy cn-using model \
            -i "${sample}_24048_0_0.dragen.cram::${sample}" \
            -f hg38_otoa.fa \
            -t hg38_otoa.bed.gz \
            -d "${sample}_depth" \
            -o "${sample}_cn" \
            -@ ${num_threads}

        # --- parascopy call ---
        log_step_time "parascopy call" "${timing_log}" parascopy call \
            -p "${sample}_cn" \
            -f hg38_otoa.fa \
            -t hg38_otoa.bed.gz \
            --freebayes /app/freebayes/build/freebayes \
            -o "${sample}_call" \
            -@ ${num_threads}

        #upload the files
        rm -rf "${sample}_cn/model"
        rm -rf "${sample}_cn/loci/*/bed"
        rm -rf "${sample}_cn/loci/*/pooled_reads"

        log_step_time "uplading parascopy cn output" "${timing_log}" upload_to_dnanexus_dir "${sample}_cn" "${dx_dest}"
        upload_timelog "${timing_log}" "${dx_dest}"

        log_step_time "uplading parascopy call output" "${timing_log}" upload_to_dnanexus_dir "${sample}_call" "${dx_dest}"
        upload_timelog "${timing_log}" "${dx_dest}"



        # Remove local CRAM/CRAI
        rm -v "${sample}_24048_0_0.dragen.cram"
        rm -v "${sample}_24048_0_0.dragen.cram.crai"
        rm -rf "${sample}_depth" ; rm -rf "${sample}_depth.tar.gz"
        rm -rf "${sample}_cn" ; rm -rf "${sample}_cn.tar.gz"
        rm -rf "${sample}_call" ; rm -rf "${sample}_call.tar.gz"
        
        # Update local checkpoint
        echo "${sample}" >> "${checkpoint_file}"
        echo "[INFO] Appended '${sample}' to checkpoint."

        # Upload the updated checkpoint to DNAnexus
        upload_checkpoint "${checkpoint_file}" "${destination_base}"

        # (Optional) Upload timing log
        upload_timelog "${timing_log}" "${dx_dest}"

    else
        echo "[WARNING] CRAM file not found for sample: ${sample}"
    fi
}

# -----------------------------------------------------------------------------
# Main logic: handle local checkpoint, possibly remove last incomplete sample
# -----------------------------------------------------------------------------
if [ -f "${destination_base_mnt}/${checkpoint_file}" ] && [ "$(wc -l < "${destination_base_mnt}/${checkpoint_file}")" -ge 1 ]; then
    echo "Local checkpoint file found: ${destination_base_mnt}/${checkpoint_file}"
    # Copy the checkpoint file to the current working directory
    cp -v "${destination_base_mnt}/${checkpoint_file}" .

    check_last_sample_completed
    status=$?

    if [ "${status}" -eq 0 ]; then
        echo "[INFO] Last sample in checkpoint is complete. We'll skip it."
        last_sample="$(tail -n 1 "${checkpoint_file}")"
        skip_until_next=false
    elif [ "${status}" -eq 1 ]; then
        echo "[INFO] Last sample in checkpoint is incomplete. We'll re-run it."
        last_sample="$(tail -n 1 "${checkpoint_file}")"
        # Remove that incomplete sample from local checkpoint
        sed -i '$d' "${checkpoint_file}"
        skip_until_next=false

        # Re-upload the checkpoint after removing the incomplete sample
        upload_checkpoint "${checkpoint_file}" "${destination_base}"
    else
        # status == 2 => checkpoint is empty or missing
        echo "[INFO] Checkpoint file is empty. We'll start from the first sample."
        last_sample=""
        skip_until_next=false
    fi
else
    # No local checkpoint file; create an empty one
    echo "No local checkpoint file. Creating one..."
    touch "${checkpoint_file}"
    last_sample=""
    skip_until_next=false

    # Upload the newly created, empty checkpoint
    upload_checkpoint "${checkpoint_file}" "${destination_base}"
fi

found_checkpoint_sample=false

# -----------------------------------------------------------------------------
# Read samples from the batch file, skip to last_sample if needed, then run pipeline
# -----------------------------------------------------------------------------
while IFS= read -r sample; do
    if [ -n "${last_sample}" ] && [ "${skip_until_next}" = false ] && [ "${found_checkpoint_sample}" = false ]; then
        if [ "${sample}" != "${last_sample}" ]; then
            continue
        else
            found_checkpoint_sample=true
            check_last_sample_completed
            status=$?
            if [ "${status}" -eq 0 ]; then
                # Already done, skip re-running
                echo "[INFO] Skipping fully completed sample: ${sample}"
                continue
            else
                # If incomplete, re-run it
                echo "[INFO] Re-running incomplete sample: ${sample}"
                dx rm -r "${destination_base}/${sample}" 2>/dev/null || true
                run_parascopy_pipeline "${sample}"
                continue
            fi
        fi
    fi

    # Normal pipeline run if not skipping
    run_parascopy_pipeline "${sample}"
done < "${batch_file}"

echo "All samples in batch ${BATCH_INDEX} processed."
echo "Done."

#remove all the files in the current directory
rm -rf ./*