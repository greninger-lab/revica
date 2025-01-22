process SELECT_REFERENCE {
    tag "$meta.id"
    label 'process_single'
    container 'quay.io/biocontainers/mulled-v2-77320db00eefbbf8c599692102c3d387a37ef02a:08144a66f00dc7684fad061f1466033c0176e7ad-0'
    
    input:
    tuple val(meta), path(bbmap_db_covstats), path(bbmap_db_log), path(fastp_trim_log)

    output:
    tuple val(meta), path("*_refs.tsv"),            optional: true, emit: refs_tsv
    tuple val(meta), path("*_failed_assembly.tsv"), optional: true, emit: failed_assembly_summary

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """

    raw_reads=0
    trimmed_reads=0

    if [ -s ${fastp_trim_log } ]; then
        raw_reads=\$(grep -A1 "before filtering:" ${fastp_trim_log} | grep 'total reads:' | cut -d: -f2 | tr -d " " | awk 'NF{sum+=\$1} END {print sum}')
        trimmed_reads=\$(grep -A1 "after filtering:" ${fastp_trim_log} | grep 'total reads:' | cut -d: -f2 | tr -d " " | awk 'NF{sum+=\$1} END {print sum}')
    else
        raw_reads=\$(grep "^Reads:" ${bbmap_db_log} | tr -cd "0-9")
        trimmed_reads=\$(grep "^Reads:" ${bbmap_db_log} | tr -cd "0-9")
    fi

    select_reference.py \\
        -bbmap_covstats ${bbmap_db_covstats} \\
        -raw_reads \$raw_reads \\
        -trimmed_reads \$trimmed_reads \\
        -b ${prefix} \\
        ${args}
    """
}
