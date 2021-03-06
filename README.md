# Different telomere length patterns between domestic and wild S. cerevisiae isolates

This repository contains supporting material for the manuscript:

"Telomeres are shorter in wild Saccharomyces cerevisiae isolates than in domesticated ones"


To clone this repository, run the following command in a local directory:

```
$ git clone https://github.com/mdangiolo89/Different-telomere-length-patterns-between-domestic-and-wild-S.-cerevisiae-isolates.git
```


Note that to run the scripts contained in this repository, you must have installed the following softwares: bwa (http://bio-bwa.sourceforge.net/bwa.shtml), samtools (http://www.htslib.org/doc/samtools.html), picardtools (https://broadinstitute.github.io/picard/), perl (https://www.perl.org/), awk (https://en.wikipedia.org/wiki/AWK). 


Please report any issues or questions to melania.dangiolo(at)unice.fr


## Sequence data
Sequence data for the strains used in this project were part of another study (https://doi.org/10.1038/s41586-018-0030-5) and were previously submitted to the Sequence Read Archive (SRA) NCBI under the accession number ERP014555. The sequence data of the simulated genome sequences generated in this study and used to validate the pipeline are available upon request.

## Sanger reads
This folder contains Sanger reads used to estimate telomere length of S. cerevisiae and S. paradoxus strains from the SGRP project.

## Simulated datasets
This folder contains the genome assemblies of 7 S. cerevisiae and 5 S. paradoxus strains modified to contain synthetic telomeres of known length. The original genome assemblies were part of another study (https://yjx1217.github.io/Yeast_PacBio_2016/welcome/). The list of synthetic telomeres which have been used for replacement is contained in the file "Synthetic_telomeric_repeats.fa".

## Correlation analysis
This folder contains a matrix with the phenotype data used to determine the association between telomere length and other variables.

## GWAS
This folder contains all the files needed to perform a genome-wide association study on our telomere length data.

Files with the genotypes of our strains (all005.bed/bim/fam/nosex) are contained in the subfolder "Base files", along with the file containing telomere length data for the same strains (GWASbase_euploiddiploid_all_TEL.txt).

The folder "QTLs analysis" contains matrixes used to generate the plots in extended data fig.7 and fig. 4B. These matrixes contain the prevalence of strains carrying more than 1 copy of CNV hits per lineage (GWAS_CN_freq>1.txt) and the prevalence of strains carrying the minor allele, either in homozygosity or in heterozygosity (GWAS_SV_freqalt.csv). In addition, the exact CN and genotype of both CNV and SNV hits is given for each isolate in the files "GWAS_CN_p005.molten.nucl.csv" (nuclear genome hits), "GWAStel_CN_p005.molten.mito.txt" (mitochondrial genome hits) and "GWAS_SV_p005.molten.csv", respectively.

## LOFs analysis
This folder contains a matrix indicating the presence (1)/absence (0) of a LOF mutation in each gene per each strain. Data are divided between Telomere Length Maintenance (TLM) and non-TLM genes. TLM genes are further divided into the ones conferring shorter/longer telomeres when deleted.


## YeaISTY (Yeast ITS, Telomeres and Y' elements estimator)
This folder contains all the files and scripts needed to estimate telomere length from whole genome sequencing data.

Files and scripts needed to run YeaISTY are contained in the subfolders "Base files" and "Source code", respectively. "Base files" contains:
- the text file used for pattern matching of telomeric motifs (motif.txt);
- bed-formatted files with genome coordinates used to calculate coverage across the whole genome (SGD_coordinatestoretain.bed) and in regions with a GC content between 50% and 80% (GCcontent5080toretain.bed), which is the same as in telomeric sequences;
- another bed-formatted file with coordinates of the subtelomeric regions (xtoendofchr.bed), starting from the X element;
- a modified SGD reference genome (SGD_ref.ytelmasked3.fa) in which all Y' elements have been masked and a long version Y' element taken from chromosome IX left has been added as an additional chromosomal entry. Moreover, all repetitive sequences in this genome, including telomeres, have been masked.

"Source code" contains the two core modules of YeaISTY (find_motif_in_reads.pl and run_mapping_sgdytelmasked.sh) plus additional scripts which are called inside these modules. In addition, the folder contains scripts to modify read names in the case they do not comply with the standard format accepted by YeaISTY (readnamemodifier_oldnameformat.pl and readnamemodifier_newnameformat.pl).

In addition, the file "SGD_ref.fa.out.gff" contains genomic coordinates that have been masked in the modified reference genome used for the mapping.

Note that the first module of YeaISTY can be used to detect whatever motif in the reads, not only telomeric ones. It is sufficient to edit the file "motif.txt" with the motif you want to search for.


### Usage manual

#### Pre-processing steps

Download the files in the "Base files" and "Source code" folder and put them in the same local directory on your computer, together with the read files of the sample you are interested in.

**VERY IMPORTANT**: the names of the read files must be in the following format in order to be processed by YeaISTY: 

>$SAMPLE.R1.fastq.gz

>$SAMPLE.R2.fastq.gz

**1.** Modify the names of the read files before proceeding with the next steps. If names are already in the right format, proceed to step 2.

**2.** Generate the FASTA files corresponding to the fastq.gz ones using these command lines:

`$ seqtk seq -a $SAMPLE.R1.fastq.gz > $SAMPLE.R1.fasta`

`$ seqtk seq -a $SAMPLE.R2.fastq.gz > $SAMPLE.R2.fasta`

**NOTE**: whatever other method to convert fastq.gz files to FASTA is acceptable, but the names of the output files must respect this format: 

>$SAMPLE.R1.fasta

>$SAMPLE.R2.fasta.

**3.** Combine the FASTA reads in a single file and remove the separate files with the following command lines:

`$ for a in *fasta; do j=${a/.R[12].fasta/}; cat $a >> $j.fasta; done`

`$ rm -i *\.R[12].fasta`

**4.** **VERY IMPORTANT**: Verify that read names are in the format accepted by YeaISTY (only one string followed by /1 or /2):

>\>HWUSI-EAS100R:6:73:941:1973#0/1

If read names are in this format, proceed to step 6. If not, they must be modified. The folder contains a pre-made script (readnamemodifier_newnameformat.pl) to convert these most common read names:

>\>EAS139:136:FC706VJ:2:2104:15343:197393 1:Y:18:ATCACG

>\>EAS139:136:FC706VJ:2:2104:15343:197393 1:N:18:1

**USAGE**

`$ perl readnamemodifier_newnameformat.pl $SAMPLE.fasta >> $SAMPLE.fasta.newname`

Alternatively, another pre-made script (readnamemodifier_oldnameformat.pl) is available to convert this less common read name format:

>\>ERR1639388.1 HX7_20360:5:2212:29965:36662/1

Please be aware that, independently of the format, the pipeline will not accept read names starting with @ and this character needs to be eliminated before proceeding to the next steps.

**USAGE**

`$ perl readnamemodifier_oldnameformat.pl A887R10.fasta >> A887R10.fasta.newname`

**5.** Delete the suffix ???newname??? from the file name. The original FASTA file will be automatically overwritten.

#### Telomere length, ITS content and Y' copy number estimation

**6.**  Scan the final FASTA file in search of telomeric motifs: 

`$ perl find_motif_in_reads.pl -i $SAMPLE.fasta -m motif.txt -o $SAMPLE.fasta.readscan -l $SAMPLE.fasta.readlist -c INT`

"i" is the input file (in FASTA format), "m" is a file containing the telomeric motifs for pattern matching, "o" is an output file containing a list of the reads classified as telomeric and the positions of their telomeric motifs, "l" is another output file containing the names of the reads classified as telomeric, "c" represents the minimum number of bp covered by telomeric motifs that must be contained in a read in order to classify it as telomeric. This value can be set by the user and must be an integer number (INT).

**7.** Map the reads on a modified reference genome containing a long-version Y' element as additional entry, and in which all telomeres and other repetitive sequences have been masked:

`$ sh run_mapping_sgdytelmasked.sh`

The main output file is $SAMPLE.lengths.txt, which contains an estimation of coverage in regions with GC content between 50 and 80%, Y' copy number, ITS content and telomere length. All estimations must be intended per haploid genome. The telomere value represents the estimation of the length of a single telomere in the sample, averaged across the whole population of telomeres. Note that ITS content and telomere length are relative estimations, not absolute ones, and a variable underestimation rate can be present among independent sequencing batches. Therefore, comparing estimations between samples which have been sequenced at different times/institutes will not give any meaningful results. 

**TIPS&TRICKS**: it is highly recommended to run YeaISTY on a server and perform steps 6 and 7 using ???nohup??? and ???&??? to ensure the process is not lost upon connection failure. Running times can vary between 30 minutes to 2 hours for step 6 and 7, depending on the sample's coverage.
