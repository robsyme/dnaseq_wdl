#-------------------------------------------------------------------------------
# DnaSeq WDL workflow
# Version1 based on GenPipes 3.1.5-beta
# Created on: 2020-06-18
#-------------------------------------------------------------------------------


import "dnaseq_tasks.wdl"
import "dnaseq_readsetScatter.wdl" as readsetScatter


#-------------------------------------------------------------------------------
# Workflow
#-------------------------------------------------------------------------------

workflow DnaSeq {

	## samples:

	Array[Object] samples

	## Species VARS:
	String SPECIES
	String ASSEMBLY
	File GENOME_FASTA
	String BWA_INDX
	File GENOME_DICT
	File DB_SNP
	File DB_SNP_COMMON
	File DB_SFP
	File IlluEXCLUSION

	## ENV VARS:
	String OUT_DIR
	String TMPDIR

	## MODULE VARS
	String MOD_PICARD
	String PICARD_HOME
	String MOD_JAVA
	String MOD_TRIMMOMATIC
	String TRIMMOMATIC_JAR
	String MOD_BWA
	String MOD_SAMTOOLS
	String MOD_SAMBAMBA
	String MOD_BVATOOLS
	String BVATOOLS_JAR
	String MOD_GATK
	String GATK_JAR
	String MOD_R
	String MOD_QUALIMAP
	String MOD_FASTQC
	String MOD_HTSLIB
	String MOD_VT
	String MOD_VCFTOOLS
	String MOD_TABIX
	String MOD_SNPEFF
	String SNPEFF_HOME
	String MOD_GEMINI
	String MOD_PYTHON
	String MOD_MUGQICTOOLS
	String PYTHON_TOOLS
	String MOD_MULTIQC

	## loop over samples then readsets

	scatter (sample in samples) {
	
		call readsetScatter.readsetScatter {

			input:
			sample = sample.sample,
			readsets = sample.readsets,

			BWA_INDX = BWA_INDX,

			TMPDIR = TMPDIR,
			MOD_JAVA = MOD_JAVA,
			MOD_PICARD = MOD_PICARD,
			PICARD_HOME = PICARD_HOME, 
			MOD_TRIMMOMATIC = MOD_TRIMMOMATIC,
			TRIMMOMATIC_JAR = TRIMMOMATIC_JAR,
			MOD_JAVA = MOD_JAVA,
			MOD_BWA = MOD_BWA

		}

		if (length(readsetScatter.OUT_BAMs) > 1){

			call dnaseq_tasks.sambamba_merge_sam_files {

				input:

				SAMPLE = sample.sample,
				PREFIX = ".sorted.bam",
				IN_BAMS = readsetScatter.OUT_BAMs,

				MOD_SAMTOOLS = MOD_SAMTOOLS,
				MOD_SAMBAMBA = MOD_SAMBAMBA

			}
		}




	}
}












