#!/usr/bin/env nextflow

/*
========================================================================================
                                    REVICA
========================================================================================
Github Repo:
https://github.com/greninger-lab/revica

Author:
Jaydee Sereewit <aseree@uw.edu>
Alex L Greninger <agrening@uw.edu>
UW Medicine | Virology
Department of Laboratory Medicine and Pathology
University of Washington
LICENSE: GNU
----------------------------------------------------------------------------------------
*/

// if INPUT not set
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }

//
// SUBWORKFLOWS
//
include { INPUT_CHECK               } from './subworkflows/input_check'
include { FASTQ_TRIM_FASTP_FASTQC   } from './subworkflows/fastq_trim_fastp_fastqc'
include { REFERENCE_PREP            } from './subworkflows/reference_prep'
include { CONSENSUS_ASSEMBLY        } from './subworkflows/consensus_assembly'

//
// MODULES
//
include { SEQTK_SAMPLE          } from './modules/seqtk_sample'
include { SUMMARY               } from './modules/summary'
include { REPORT_FAILED_SAMPLES } from './modules/report_failed_samples'

////////////////////////////////////////////////////////
////////////////////////////////////////////////////////
/*                                                    */
/*                 RUN THE WORKFLOW                   */
/*                                                    */
////////////////////////////////////////////////////////
////////////////////////////////////////////////////////

log.info "                                                            "
log.info " _|_|_|    _|_|_|_|  _|      _|  _|_|_|    _|_|_|    _|_|   " 
log.info " _|    _|  _|        _|      _|    _|    _|        _|    _| " 
log.info " _|_|_|    _|_|_|    _|      _|    _|    _|        _|_|_|_| " 
log.info " _|    _|  _|          _|  _|      _|    _|        _|    _| " 
log.info " _|    _|  _|_|_|_|      _|      _|_|_|    _|_|_|  _|    _| "
log.info "                                                            "

workflow {
    
    INPUT_CHECK (
        ch_input
    )

    FASTQ_TRIM_FASTP_FASTQC (
        INPUT_CHECK.out.reads,
        params.adapter_fasta,
        params.save_trimmed_fail,
        params.save_merged,
        params.skip_fastp,
        params.skip_fastqc
    )

    if(params.sample) {
        SEQTK_SAMPLE (
            FASTQ_TRIM_FASTP_FASTQC.out.reads,
            params.sample
        )
        ch_ref_prep_input = SEQTK_SAMPLE.out.reads
    } else {
        ch_ref_prep_input = FASTQ_TRIM_FASTP_FASTQC.out.reads
    } 

    ch_trim_log = FASTQ_TRIM_FASTP_FASTQC.out.trim_log

    ch_ref_prep_input
    .join(ch_trim_log, by: [0]) 
    .set { ch_ref_prep_combined }

    REFERENCE_PREP (
        ch_ref_prep_combined,
        file(params.db),
    )
    
    REFERENCE_PREP
        .out.failed_assembly_summary
        .map { meta, path -> path }
        .collectFile(storeDir: "${params.output}", name: "${params.run_name}_fail_summary.tsv", keepHeader: true, sort: true)
        .set { run_sum_tsv_fail }
    
    CONSENSUS_ASSEMBLY (
        REFERENCE_PREP.out.reads,
        REFERENCE_PREP.out.ref,
    )
    
    FASTQ_TRIM_FASTP_FASTQC.out.trim_log
        .combine(CONSENSUS_ASSEMBLY.out.consensus
            .join(CONSENSUS_ASSEMBLY.out.bam, by: [0,1]), by: 0)
        .map { meta, trim_log, ref_info, consensus, bam, bai -> [ meta, ref_info, trim_log, consensus, bam, bai ] }
        .set { ch_summary_in }

    SUMMARY (
        ch_summary_in
    )

    SUMMARY.out.summary
        .collectFile(storeDir: "${params.output}", name:"${params.run_name}_summary.tsv", keepHeader: true, sort: true)
        .set { run_sum_tsv_pass }

    REPORT_FAILED_SAMPLES (
        run_sum_tsv_pass,
        run_sum_tsv_fail
    )

}
