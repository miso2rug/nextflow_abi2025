params.out = "${projectDir}/output"
params.url = "https://tinyurl.com/cqbatch1"
params.prefix = "sequence_"

process downloadFile {
    publishDir params.out, mode: "copy", overwrite : true
    output:
        path "multi_seqs.fasta"
    script:
        """
        wget "${params.url}" -O "multi_seqs.fasta"
        """
}

process countSeqs {
    publishDir params.out, mode: "copy", overwrite : true
    input:
        path infile
    output:
        path "number_seqs.txt"
    script:
        """
        grep ">" ${infile} | wc -l > number_seqs.txt
        """
}

process splitSeqs {
    publishDir params.out, mode: "copy", overwrite : true
    input:
        path infile
    output:
        path "${params.prefix}*.fasta"
    script:
        """
        split -l 2 -d --additional-suffix .fasta ${infile} ${params.prefix}

        """
}

workflow {
    download_ch = downloadFile()
    countSeqs(download_ch)
    splitSeqs(download_ch)
}
