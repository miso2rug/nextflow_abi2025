nextflow.enable.dsl=2
// recommended when script should run on older versions, since previosly "grammar" 1 (dsl=1) was default, newer versions have default dsl=2

params.out = "${projectDir}/output"
// params - implicit variable, similar to dictionary, can hand over flags like "nextflow script.nf --out testpath if params has key for that (params.out, can be initilased for cases where no flag is handed over params.out = "path"
params.url = "https://tinyurl.com/cqbatch1"

process downloadFile {
    publishDir params.out, mode: "copy", overwrite : true
    // mode copy actually copies the output to the def. pubDir, otherwise its just linked to the resp. workDir
    // projectDir is a predefined variable translating to the absolute path of where the x.nf script is stored (same as baseDir)
    // launchDir = where you started the x.nf script from
    // ${} in a "string" similar to f-strings in python
    output:
        path "batch1.fasta"
    script: // What should the worker do?
        """
        wget ${params.url} -O batch1.fasta
        """
}

process countSeq {
    publishDir params.out, mode: "copy", overwrite : true
    input:
        path fastafile
    // links to the workdirectory of the previous process and what was defined as output, unrelated to publishDir (but whats not defined as output cannot be published)
    output:
        path "num_seqs.txt"
    script:
        """
        grep ">" ${fastafile} | wc -l > num_seqs.txt
        """
}

workflow {
    download_channel = downloadFile()
    countSeq(download_channel)
}
