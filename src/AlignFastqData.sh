# Script performs the following on input fastq file ($3):
# 1. Quality check of data with FastQC
# 2. Alignment of data with bowtie2 against reference genome ($1), with ($2) threads
# 3. Runs PicardTools SamToBam
# 4. Sorts the bam alignment by position using PicardTools

echo Script name: $0
echo $# arguments were passed...
if [ "$#" -ne 3 ]; then
  echo "Illegal number of parameters, four (including script) expected:"
  echo "Usage: <exe> <reference> <n_threads> <fq_data>"
  exit 1
fi

# Better variable names
reference=$1
n_threads=$2
fq_data=$3

# Run fastqc.
# Only save the summary.txt file which provides outcome (PASS, WARN, FAIL) 
# of each test. 
fastqc $fq_data
unzip ${fq_data::(-9)}_fastqc.zip
mv ${fq_data::(-9)}_fastqc/summary.txt ${fq_data::(-9)}_summary.txt
rm ${fq_data::(-9)}_fastqc.html
rm -rf ${fq_data::(-9)}_fastqc

# Align data with bowtie2.
bowtie2 --threads $n_threads -x $reference -U $fq_data -S ${fq_data::(-9)}.sam

# Convert sam to bam with PicardTools SamFormatConverter
java -jar /home/local/ARCS/ic2465/RabadanRotation/software/PicardTools/picard.jar SamFormatConverter \
  I=${fq_data::(-9)}.sam \
  O=${fq_data::(-9)}.unsorted.bam
rm ${fq_data::(-9)}.sam # cleanup

# Sort bam by coordinate
java -jar /home/local/ARCS/ic2465/RabadanRotation/software/PicardTools/picard.jar SortSam \
  I=${fq_data::(-9)}.unsorted.bam \
  O=${fq_data::(-9)}.bam \
  SORT_ORDER=coordinate
rm ${fq_data::(-9)}.unsorted.bam # cleanup
