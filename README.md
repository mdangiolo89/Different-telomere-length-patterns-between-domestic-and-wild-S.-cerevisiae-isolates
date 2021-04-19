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

Files and scripts needed to reproduce the analyses are contained in the subfolders "Base files" and "Source code", respectively. "Base files" contains the *S. cerevisiae* (DBVPG6765.genome.fa) and *S. paradoxus* (CBS432.genome.fa) reference genomes used in this paragraph of the manuscript, their subtelomeric coordinates (DBVPG6765.subtel.txt and CBS432.subtel.txt) and a list of reliable markers (DBVPG6765_CBS432_LOHmarkers.txt) used to define loss-of-heterozygosity (LOH) regions in the living ancestor and introgression regions in the Alpechin, Brazilian bioethanol, Mexican agave and French Guyana clades.

To reproduce the analyses performed in the paper, download the reads for the sample SAMN13540515 from the SRA, NCBI archive. These reads correspond to the living ancestor.


### Usage
Download the files in the "Base files" and "Source code" folder and put them in the same local directory on your computer, together with the example reads downloaded from the SRA, NCBI archive. Prior to start the analysis, ensure that the files "sample_infoDBV.txt" and "sample_infoCBS.txt" contain the prefix of the example reads (BCM_AQF) and the prefix of the reference genome on which you want to perform the mapping and variant calling (DBVPG6765 for "sample_infoDBV.txt" and CBS432 for "sample_infoCBS.txt"). If you want to perform this analysis on other samples included in the paper, ensure to change the corresponding strings in the files "sample_infoDBV.txt" and "sample_infoCBS.txt".
In addition, before starting the analysis it is necessary to decompress the file "DBVPG6765_CBS432_LOHmarkers.txt.tar.gz" and name it "DBVPG6765_CBS432_LOHmarkers.txt".

To launch the analysis, type on the command line:

```
$ sh annotateSparLOHintrogressions.sh

$ sh annotateScerLOHintrogressions.sh
```

Since the analysis might take long to perform, it is recommended to use the options "nohup" to ensure that the process keeps running if the connection with the server is lost, and "&" to launch the process in background.
The pipelines will produce many intermediate files, including bam files, vcf files and coverage files. The final files have the suffix "[CDH].annotation and contain coordinates of homozygous DBVPG6765 (D.annotation) or CBS432 (C.annotation) regions or heterozygous regions (H.annotation), in bed format. For a correct interpretation of the results, it is essential to consider the genomic background of your sample. In the case of the hybrid genome of the living ancestor and its derived clones, the coordinates included in the "$sample....C.annotation" file must be considered as homozygous CBS432 (*S. paradoxus*) LOH, the coordinates included in the "$sample....D.annotation" file must be considered as homozygous DBVPG6765 (*S. cerevisiae*) LOH and the coordinates included in the "$sample....H.annotation" file must be considered as heterozygous regions of the genome.
In the case of the Alpechins, the coordinates included in the "$sample....C.annotation" file must be annotated as homozygous CBS432 (*S. paradoxus*) introgressions, and the coordinates included in the "$sample....H.annotation" file must be annotated as heterozygous CBS432 (*S. paradoxus*) introgressions.

Note that the same set of scripts has been used to annotate LOH and introgression regions in other samples included in the paper, which have a different structure in the name of their reads. For these additional samples, a modified version of the pipeline must be used and is available upon request.

Pan-introgression maps for all the introgressed clades (Alpechin, Brazilian bioethanol, Mexican agave and French Guyana) and LOH maps of the living ancestor are provided in separate subfolders.
