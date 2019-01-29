# Script takes in a list of SRA run names and downloads the fastq data
# associated for the run. For each run name the data is written to file
# sra_run_name.fasta and then gzipped.

sraruns=$1
command=$2

for sra in `cat $1`; do
  $command $sra
  gzip $sra.fastq
done
