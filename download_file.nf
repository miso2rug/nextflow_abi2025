nextflow.enable.dsl=2
// recommended when script should run on older versions, since previosly "grammar" 1 (dsl=1) was default, newer versions have default dsl=2

process downloadFile {
    publishDir "${projectDir}/output", mode: "copy", overwrite : true
    // mode copy actually copies the output to the def. pubDir, otherwise its just linked to the resp. workDir
    // projectDir is a predefined variable translating to the absolute path of where the x.nf script is stored
    // launchDir = where you started the x.nf script from
    // ${} in a "string" similar to f-strings in python
    output:
        path "batch1.fasta"
    script: // What should the worker do?
        """
        wget https://tinyurl.com/cqbatch1 -O batch1.fasta
        """
}

workflow {
    downloadFile()
}
