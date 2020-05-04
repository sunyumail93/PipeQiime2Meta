#!/usr/bin/env bash
#PipeQiime2Meta_QC.sh
#This is an optional step to run FastQC program on the data, then report using MultiQC
#Version: Yu H. Sun, 2020-05-01

#Those two files can be downloaded from SILVA32 database:
if [ ! -n "$1" ];then
  echo "********************************************************************************"
  echo "*                     Welcome to use PipeQiime2Meta_QC.sh                      *"
  echo "*This is an optional QC step using FastQC program, then report using MultiQC   *"
  echo "*Please make sure fastqc and MultiQC have been installed                       *"
  echo "*[Usage]: PipeQiime2Meta_QC.sh [Path_to_data_directory]                        *"
  echo "********************************************************************************"
else
  echo "Start runnning PipeQiime2Meta_QC.sh"
  
  module load fastqc
  module load anaconda3/5.2.0b
  path=$1
  echo "Analyzing: "$path  
  [ ! -d data_fastqc ] && mkdir data_fastqc
  
  for data in ${path}/*
  	do echo $data
        base=`basename $data`
#	echo $base
  	fastqc -f fastq -o data_fastqc $data 2> data_fastqc/$base.fastqc.log
  done

  multiqc .

fi
