process REPORT_FAILED_SAMPLES {
    tag "${failed_runs_summary_tsv}"
    label 'process_low'
    container 'quay.io/jefffurlong/revica:ubuntu-20.04'

    input: 
    path(run_summary_tsv)
    path(failed_runs_summary_tsv)

    output: 
    path("${run_summary_tsv}")

    script:
    """

    if [ ! -s $run_summary_tsv ]; then
        echo "Run summary file not located! No merging will be performed."

    elif [ ! -s $failed_runs_summary_tsv ]; then
        echo "Did not find a failed run summary tsv! No merging will be performed."

    else

        merge_failed.py ${run_summary_tsv} ${failed_runs_summary_tsv}
        rm ${failed_runs_summary_tsv}

    fi

    """
}
