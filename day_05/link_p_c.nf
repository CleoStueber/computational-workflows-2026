#!/usr/bin/env nextflow

process SPLITLETTERS {
    input:
    tuple val(meta), val(in_str), val(prefix)

    output:
    tuple val(meta), path("${prefix}_*")

    script:
    """
    echo -n "$in_str" | split -b ${meta.block_size} - ${prefix}_
    """
} 

process CONVERTTOUPPER {
    debug true

    publishDir 'results', mode: 'copy'

    input:
    path input_file

    output:
    path "${input_file.baseName}_upper.txt"

    script:
    """
    tr '[:lower:]' '[:upper:]' < $input_file | tee ${input_file.baseName}_upper.txt
    """
} 

workflow { 
    // 1. Read in the samplesheet (samplesheet_2.csv)  into a channel. The block_size will be the meta-map
    // 2. Create a process that splits the "in_str" into sizes with size block_size. The output will be a file for each block, named with the prefix as seen in the samplesheet_2
    // 4. Feed these files into a process that converts the strings to uppercase. The resulting strings should be written to stdout

    // read in samplesheet}
    in_ch = channel.fromPath('samplesheet_2.csv')
        .splitCsv(header: true)
        .map { row ->
            [
                [block_size: row.block_size],
                row.input_str,
                row.out_name
            ]
        }
    in_ch.view()

    // split the input string into chunks
    split_ch = SPLITLETTERS(in_ch)
    split_ch.view()

    // lets remove the metamap to make it easier for us, as we won't need it anymore
    files_ch = split_ch
        .map { meta, files -> files }
        .flatten()
    
    // convert the chunks to uppercase and save the files to the results directory
    CONVERTTOUPPER(files_ch)
}