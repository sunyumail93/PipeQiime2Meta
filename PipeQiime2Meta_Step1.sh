#!/usr/bin/env bash
#PipeQiime2Meta_Step1.sh
#This is a pipeline for Qiime2 metagenomic analysis
#Version: Yu H. Sun, 2020-01-08

if [ ! -n "$1" ]
then
  echo "********************************************************************************************"
  echo "*                PipeQiime2Meta.sh: Pipeline for Qiime2 metagenomic analysis               *"
  echo "*Part 1 of the pipeline: importing data and QC                                             *"
  echo "*Files in the InputDir must follow this format: .+_.+_L[0-9][0-9][0-9]_R[12]_001.fastq.gz  *"
  echo "*If you are not sure about datanames, check the example dataset:                           *"
  echo "*https://data.qiime2.org/2019.10/tutorials/importing/casava-18-paired-end-demultiplexed.zip*"
  echo "*Files must be demultiplexed, and this is for Casava importing                             *"
  echo "*If Output Prefix not specified, use default prefix = data                                 *"
  echo "*Usage: `basename $0` [InputDir] [OuputPrefix|Optional, Default no prefix]       *"
  echo "*Example: PipeQiime2Meta_Step1.sh Example Test                                             *"
  echo "********************************************************************************************"
else

Data=$1
if [ ! -n "$2" ];then
    Pre=""
    OurpurPrefix="data"
else
    Pre=$2
    OurpurPrefix=${Pre}_data
fi
  echo "*****************************************************************"
  echo "*  PipeQiime2Meta.sh: Pipeline for Qiime2 metagenomic analysis  *"
  echo "*       Part 1 of the pipeline: importing data and QC           *"
  echo "*****************************************************************"
echo "1. Staring Qiime2 pipeline"
echo "   Loading Qiime2"
module load qiime/2019.4
source activate qiime2-2019.4
echo "   Data Folder Name: "$Data
echo "   Output Data Prefix: "$OurpurPrefix
echo ""

echo "2. Importing data"
echo "   qiime tools import --type SampleData[PairedEndSequencesWithQuality] --input-path "$Data" --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path "${OurpurPrefix}.qza
#qiime tools import --type SampleData[PairedEndSequencesWithQuality] --input-path $Data --input-format CasavaOneEightSingleLanePerSampleDirFmt --output-path ${OurpurPrefix}.qza
qiime tools import \
    --type SampleData[PairedEndSequencesWithQuality] \
    --input-path $Data \
    --input-format CasavaOneEightSingleLanePerSampleDirFmt \
    --output-path ${OurpurPrefix}.qza
echo ""

echo "3. Summarizing data for QC"
echo "   qiime demux summarize --i-data "$OurpurPrefix.qza" --o-visualization "$OurpurPrefix
qiime demux summarize --i-data $OurpurPrefix.qza --o-visualization $OurpurPrefix
echo ""

echo "4. Done PipeQiime2Meta Part1"
echo "   Qiime2 visualization: https://view.qiime2.org/"
echo "   See output: "${OurpurPrefix}.qzv

fi
