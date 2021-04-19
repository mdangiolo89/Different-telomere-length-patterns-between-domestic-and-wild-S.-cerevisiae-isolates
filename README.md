# Different telomere length patterns between domestic and wild S. cerevisiae isolates

This repository contains supporting material for the manuscript:

"Different telomere length patterns between domestic and wild S. cerevisiae isolates"


To clone this repository, run the following command in a local directory:

```
$ git clone https://github.com/mdangiolo89/Different-telomere-length-patterns-between-domestic-and-wild-S.-cerevisiae-isolates.git
```


Note that to run the scripts contained in this repository, you must have installed the following softwares: bwa (http://bio-bwa.sourceforge.net/bwa.shtml), samtools (http://www.htslib.org/doc/samtools.html), picardtools (https://broadinstitute.github.io/picard/), perl (https://www.perl.org/), awk (https://en.wikipedia.org/wiki/AWK). 


Please report any issues or questions to melania.dangiolo(at)unice.fr


## Sequence data
Sequence data for the strains used in this project were part of another study (https://doi.org/10.1038/s41586-018-0030-5) and were previously submitted to the Sequence Read Archive (SRA) NCBI under the accession number ERP014555. The simulated genome sequences generated in this study and used to validate the pipeline are available upon request.


## Simulated datasets
This folder contains the genome assemblies of 7 S. cerevisiae and 5 S. paradoxus strains modified to contain synthetic telomeres of known length. The original genome assemblies were part of another study (https://yjx1217.github.io/Yeast_PacBio_2016/welcome/). The list of synthetic telomeres which have been used for replacement is contained in the file "Synthetic_telomeric_repeats.fa".

## Telomere length estimation pipeline
This folder contains all files and scripts needed to estimate telomere length from whole genome sequencing data (WGS).

Files and scripts needed to run the pipeline are contained in the subfolders "Base files" and "Source code", respectively. "Base files" contains:
- the text file used for pattern matching of telomeric motifs (motif.txt);
- bed-formatted files with genome coordinates used to calculate coverage across the whole genome (SGD_coordinatestoretain.bed) and in regions with a GC content between 50% and 80% (GCcontent5080toretain.bed), which is the same as in telomeric sequences;
- another bed-formatted file with coordinates of the subtelomeric regions (xtoendofchr.bed), starting from the X element;
- a modified SGD reference genome (SGD_ref.ytelmasked3.fa) in which all Y' elements have been masked and a long version Y' element taken from chromosome IX left has been added as an additional chromosomal entry. Moreover, all repetitive sequences in this genome, including telomeres, have been masked.

"Source code" contains the two core modules of the pipeline (find_motif_in_reads.pl and run_mapping_sgdytelmasked.sh) plus additional scripts which are called inside these modules. In addition, the folder contains scripts to modify read names in the case they do not comply with the standard format accepted by the pipeline (readnamemodifier_oldnameformat.pl and readnamemodifier_newnameformat.pl).

Note that the first module of the pipeline can be used to detect whatever motif in the reads, not only telomeric ones. It is sufficient to edit the file "motif.txt" with the motif you want to search for.

### Protocol

#### Pre-processing steps

**VERY IMPORTANT**: the names of the read files must be in the following format in order to be processed by the pipeline: 

>$SAMPLE.R1.fastq.gz

>$SAMPLE.R2.fastq.gz

**1.** Modify the names of the reads files before proceeding with the next steps. If names are already in the right format, proceed to step 2.

**2.** Generate the FASTA files corresponding to the fastq.gz ones using these command lines:

`$ seqtk seq -a $SAMPLE.R1.fastq.gz > $SAMPLE.R1.fasta`

`$ seqtk seq -a $SAMPLE.R2.fastq.gz > $SAMPLE.R2.fasta`

**NOTE**: whatever other method to convert fastq.gz files to FASTA is acceptable, but the names of the output files must respect this format: 

>$SAMPLE.R1.fasta

>$SAMPLE.R2.fasta.

**3.** Combine the FASTA reads in a single file and remove the separate files with the following command lines:

`$ for a in *fasta; do j=${a/.R[12].fasta/}; cat $a >> $j.fasta; done`
`$ rm -i *\.R[12].fasta`

**4.** Verify that read names are in the format accepted by the pipeline:

>@HWUSI-EAS100R:6:73:941:1973#0/1

If read names are in this format, proceed to step 6. If not, they must be modified. The folder contains a pre-made script (readnamemodifier_newnameformat.pl) to convert the most common read names to the format accepted by the pipeline:

>@EAS139:136:FC706VJ:2:2104:15343:197393 1:Y:18:ATCACG

>@EAS139:136:FC706VJ:2:2104:15343:197393 1:N:18:1

**USAGE**

`$ perl readnamemodifier_newnameformat.pl $SAMPLE.fasta >> $SAMPLE.fasta.newname`

Alternatively, another pre-made script (readnamemodifier_oldnameformat.pl) is available to convert the less common read name format:

>\>ERR1639388.1 HX7_20360:5:2212:29965:36662/1

**USAGE**

`$ perl readnamemodifier_oldnameformat.pl A887R10.fasta >> A887R10.fasta.newname`

**5.** Delete the suffix “newname” from the file names. The original FASTA file will be automatically overwritten.

#### Telomere length, ITS content and Y' copy nuber estimation

**6.**  Scan the reads file in search of telomeric motifs: 

`$ perl find_motif_in_reads.pl -i $SAMPLE.fasta -m motif.txt -o $SAMPLE.fasta.readscan -l $SAMPLE.fasta.readlist -c INT`

"i" is the input file (in FASTA format), "m" is a file containing the telomeric motifs for pattern matching, "o" is an output file containing a list of the reads classified as telomeric and the positions of their telomeric motifs, "l" is another output file containing the names of the reads classified as telomeric, "c" represents the minimum number of bp covered by telomeric motifs that must be contained in a read in order to classify it as telomeric. This value can be set by the user and must be an integer number (INT).

**7.** Map the reads on a modified reference genome containing a long-version Y' element as additional entry and in which all telomeres and other repetitive sequences have been masked:

`$ sh run_mapping_sgdytelmasked.sh`

The main output file is $SAMPLE.lengths.txt, which contains an estimation of coverage in regions with GC content between 50 and 80%, Y' copy number, ITS content and telomere length. All estimations must be intended per haploid genome. The telomere value represents the estimation of the length of a single telomere in the sample, averaged across the whole population of telomeres. 

**TIPS&TRICKS**: it is highly recommended to run the pipeline on a server and perform steps 6 and 7 using “nohup” and “&” to ensure the process is not lost upon connection failure. Running times can vary between 30 minutes to 2 hours for step 6 and 7, depending on the sample's coverage.
