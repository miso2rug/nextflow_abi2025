params.out = "${projectDir}/output"
params.cache = "${projectDir}/cache"
//params.url = "https://tinyurl.com/cqbatch1"
params.prefix = "sequence_"
params.url = null
params.indir = null


process downloadFile {
    publishDir params.out, mode: "copy", overwrite : true
    storeDir params.cache
    output:
        path "multi_seqs.fasta"
    script:
        """
        wget "${params.url}" -O "multi_seqs.fasta"
        """
}

process countSeqs {
    publishDir params.out, mode: "copy", overwrite : true
    storeDir params.cache
    input:
        path infile
    output:
        path "${infile.getSimpleName()}_number_seqs.txt"
    script:
        """
        grep ">" ${infile} | wc -l > ${infile.getSimpleName()}_number_seqs.txt
        """
}

process splitSeqs {
    publishDir params.out, mode: "copy", overwrite : true
    storeDir params.cache
    input:
        path infile
    output:
        path "${params.prefix}*_${infile.getSimpleName()}.fasta"
    script:
        """
        split -l 2 -d --additional-suffix _${infile.getSimpleName()}.fasta ${infile} ${params.prefix}

        """
}

process countBases {
    publishDir params.out, mode: "copy", overwrite : true
    storeDir params.cache
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
    storeDir params.cache
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
    storeDir params.cache
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
    if (params.url != null && params.indir == null) {
        download_ch = downloadFile()
    }
    else if (params.indir != null && params.url == null) {
        download_ch = channel.fromPath("${params.indir}/*.fasta")
    }
    else {
        print("ERROR: Please provide either --url or --indir")
        System.exit(1)
    }
    countSeqs(download_ch)
    sequence_ch = splitSeqs(download_ch).flatten()
    countBases(sequence_ch)
    repeats_ch = countRepeats(sequence_ch).collect()
    makeSummary(repeats_ch)
}
