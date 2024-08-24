process SUMMARY {
    tag "${meta.id}_${ref_info.acc}_${ref_info.tag}"
    label 'process_low'
    container 'quay.io/jefffurlong/revica:ubuntu-20.04'

    input:
    tuple val(meta), val(ref_info), path(fastp_trim_log), path(consensus), path(bam), path(bai)

    output:
    path("*.tsv"), emit: summary

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: ''

    """
    # raw reads and trimmed reads
    raw_reads=\$(grep -A1 "before filtering:" ${fastp_trim_log} | grep 'total reads:' | cut -d: -f2 | tr -d " " | awk 'NF{sum+=\$1} END {print sum}')
    trimmed_reads=\$(grep -A1 "after filtering:" ${fastp_trim_log} | grep 'total reads:' | cut -d: -f2 | tr -d " " | awk 'NF{sum+=\$1} END {print sum}')
    pct_reads_trimmed=\$(echo "\${trimmed_reads}/\${raw_reads}*100" | bc -l)
    pct_reads_trimmed_formatted=\$(printf "%.2f" "\${pct_reads_trimmed}")

    # mapped reads
    mapped_reads=\$(samtools view -F 4 -c ${bam})
    pct_reads_mapped=\$(echo "\${mapped_reads}/\${raw_reads}*100" | bc -l)
    pct_reads_mapped_formatted=\$(printf "%.2f" "\${pct_reads_mapped}")

    # whole genome coverage
    pct_genome_covered=\$(samtools coverage ${bam} | awk 'NR>1' | cut -f6)
    pct_genome_covered_formatted=\$(printf "%.2f" "\${pct_genome_covered}")
    mean_genome_coverage=\$(samtools coverage ${bam} | awk 'NR>1' | cut -f7)
    mean_genome_coverage_formatted=\$(printf "%.2f" "\${mean_genome_coverage}")
    
    # consensus genome
    consensus_length=\$(awk '/^>/{if (l!="") print l; print; l=0; next}{l+=length(\$0)}END{print l}' ${consensus} | awk 'FNR==2{print val,\$1}')
    num_ns_consensus=\$(grep -v "^>" ${consensus} | tr -c -d N | wc -c)
    pct_ns=\$(echo "\${num_ns_consensus}/\${consensus_length}*100" | bc -l | awk 'FNR==1{print val,\$1}')
    pct_ns_formatted=\$(printf "%.4f" "\${pct_ns}")
    num_as_consensus=\$(grep -v "^>" ${consensus} | tr -c -d A | wc -c)
    num_cs_consensus=\$(grep -v "^>" ${consensus} | tr -c -d C | wc -c)
    num_gs_consensus=\$(grep -v "^>" ${consensus} | tr -c -d G | wc -c)
    num_ts_consensus=\$(grep -v "^>" ${consensus} | tr -c -d T | wc -c)
    num_non_ns_ambiguous=\$(echo "\${consensus_length}-\${num_as_consensus}-\${num_cs_consensus}-\${num_gs_consensus}-\${num_ts_consensus}-\${num_ns_consensus}" | bc -l)
    

    echo "sample_name\traw_reads\ttrimmed_reads\tpct_reads_trimmed\tref_tag\tref_acc\tref_header\tmapped_reads\tpct_reads_mapped\tpct_genome_covered\tmean_genome_coverage\tconsensus_length\tnum_ns\tpct_ns\tnum_ambiguous" > ${prefix}.summary.tsv
    echo "${meta.id}\t\${raw_reads}\t\${trimmed_reads}\t\${pct_reads_trimmed_formatted}\t${ref_info.tag}\t${ref_info.acc}\t${ref_info.header}\t\${mapped_reads}\t\${pct_reads_mapped_formatted}\t\${pct_genome_covered_formatted}\t\${mean_genome_coverage_formatted}\t\${consensus_length}\t\${num_ns_consensus}\t\${pct_ns_formatted}\t\${num_non_ns_ambiguous}" >> ${prefix}.summary.tsv
    """
}
