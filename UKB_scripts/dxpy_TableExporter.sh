dx run table-exporter \
    -idataset_or_cohort_or_dashboard=record-GpX5qZjJqGz0XZ50jzZfgz7f \
    -ioutput="test" \
    -ifield_names_file_txt="file-GzVV28jJ0jGqFY0jVbZXQYQb" \
    -icoding_option="RAW" \
    -iheader_style="UKB-FORMAT" \
    -ioutput_format="TSV" \
    --destination="UKB_Parascopy:/pheno_files" \
    --yes

dx run table-exporter \
    -idataset_or_cohort_or_dashboard=record-GpX5qZjJqGz0XZ50jzZfgz7f \
    -ioutput="test" \
    -ifield_names="eid" \
    -ifield_names="p130000" \
    -icoding_option="RAW" \
    -iheader_style="UKB-FORMAT" \
    -ioutput_format="TSV" \
    --destination="UKB_Parascopy:/pheno_files" \
    --yes
