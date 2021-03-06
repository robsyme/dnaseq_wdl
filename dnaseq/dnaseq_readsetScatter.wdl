#-------------------------------------------------------------------------------
# DnaSeq WDL workflow
# Version1 based on GenPipes 3.1.5-beta
# Created on: 2020-07-18
#-------------------------------------------------------------------------------

import "genpipes_tasks.wdl"


workflow readsetScatter {

  String SAMPLE
  Array[Object] READSETS
  
  String BWA_INDX

  String TMPDIR
  String MOD_JAVA
  String MOD_PICARD
  String PICARD_HOME
  String MOD_TRIMMOMATIC
  String TRIMMOMATIC_JAR
  String MOD_BWA


  scatter(readset in READSETS){

      String ADAPTER1 = readset.adapter1
      String ADAPTER2 = readset.adapter2


    if (readset.bam != "None"){

      call genpipes_tasks.picard_sam_to_fastq {

        input:
        READSET = readset.readset,
        IN_BAM = readset.bam,
        TMPDIR = TMPDIR,
        MOD_JAVA = MOD_JAVA,
        MOD_PICARD = MOD_PICARD,
        PICARD_HOME = PICARD_HOME

      }
    }

    call genpipes_tasks.trimmomatic {

      input:
      READSET = readset.readset,
      IN_FQ1 = select_first([picard_sam_to_fastq.OUT_FQ1, readset.fastq1]),
      IN_FQ2 = select_first([picard_sam_to_fastq.OUT_FQ2, readset.fastq2]),
      ADAPTER1 = readset.adapter1,
      ADAPTER2 = readset.adapter2,
      MOD_JAVA = MOD_JAVA,
      MOD_TRIMMOMATIC = MOD_TRIMMOMATIC,
      TRIMMOMATIC_JAR = TRIMMOMATIC_JAR

    }

    call genpipes_tasks.bwa_mem_picard_sort_sam {

      input:
      READSET = readset.readset,
      IN_FQ1 = trimmomatic.OUT_FQ1_TRIM,
      IN_FQ2 = trimmomatic.OUT_FQ2_TRIM,
      BWA_INDX = BWA_INDX,
      MOD_JAVA = MOD_JAVA,
      MOD_BWA = MOD_BWA,
      MOD_PICARD = MOD_PICARD,
      PICARD_HOME = PICARD_HOME,
      TMPDIR = TMPDIR
      
    }


    output {

      Array[File] OUT_BAMs = bwa_mem_picard_sort_sam.OUT_BAM
      Array[String] ADPTER1 = ADAPTER1
      Array[String] ADPTER2 = ADAPTER2

    }

  }

}