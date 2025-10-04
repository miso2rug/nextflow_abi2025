nextflow.enable.dsl=2
// recommended when script should run on older versions, since previosly "grammar" 1 (dsl=1) was default, newer versions have default dsl=2

process downloadFile {
    publishDir "/home/aylin/projects/nextflow_abi2025/output/", mode: "copy", overwrite : true
    // mode copy actually copies the output to the def. pubDir, otherwise its just linked to the resp. workDir
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
