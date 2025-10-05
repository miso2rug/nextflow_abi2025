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

process countBases {
    publishDir params.out, mode: "copy", overwrite : true
    input:
        path fastafile
    output:
        path "${fastafile.getSimpleName()}_basecount.txt"
    script:
        """
        tail -n 1 ${fastafile} | wc -m > ${fastafile.getSimpleName()}_basecount.txt
        """
}

process countRepeats {
    publishDir params.out, mode: "copy", overwrite : true
    input:
        path fastafile
    output:
        path "${fastafile.getSimpleName()}_gccgcg_count.txt"
    script:
        """
        grep "GCCGCG" -o ${fastafile} | wc -l > ${fastafile.getSimpleName()}_gccgcg_count.txt
        """
}

process makeSummary {
    publishDir params.out, mode: "copy", overwrite : true
    input:
        path fastafiles
    output:
        path "report.csv"
    script:
        """
        for f in \$(${fastafiles} | ls seq*.txt); do echo \$f | cut -d "_" -f 1,2 -z; echo -n ": "; cat \$f; done > report.csv
        """

}

workflow {
    download_ch = downloadFile()
    countSeqs(download_ch)
    sequence_ch = splitSeqs(download_ch).flatten()
    // sequence_ch.view() - puts out content of channel in terminal, mostly used for trouble shooting
    // channel.flatten() - seperates bundeled multi-file output into single files before next process
    countBases(sequence_ch)
    repeats_ch = countRepeats(sequence_ch).collect()
    // channel.collect() reverse functional to .flatten()
    makeSummary(repeats_ch)
}
