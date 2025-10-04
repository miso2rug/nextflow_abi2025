nextflow.enable.dsl=2 // recommended when script should run on older versions, since previosly "grammar" 1 (dsl=1) was default, newer versions have default dsl=2

process downloadFile {
    // What should the worker do?
    """
    wget https://tinyurl.com/cqbatch1 -O batch1.fasta
    """
}

workflow {
    downloadFile()
}
