#!/usr/bin/env bash
#PipeQiime2Meta_Step2.sh
#This is a pipeline for Qiime2 metagenomic analysis, part 2
#Version: Yu H. Sun, 2020-01-09

if [ ! -n "$1" ]
then
  echo "********************************************************************************************"
  echo "*                PipeQiime2Meta.sh: Pipeline for Qiime2 metagenomic analysis               *"
  echo "*Part 2 of the pipeline: DATA2, feature-table, alignment, phylogeny                        *"
  echo "*DATA2 step is time consuming, which may take a few days. Please use as much RAM and CPUs  *"
  echo "*Suggested RAM=96000, time about 24h at least                                              *"
  echo "*Make sure the OutputPrefix must be same as the one in Step 1, default = data              *"
  echo "*Usage: `basename $0` [InputDir] [MetaTable.csv|Required file]                   *" 
  echo "*      Optional: [OuputPrefix|Default no prefix] [LeftTr|Default 270] [RightTr|Default 250]*"
  echo "*                [Left5endTr|Default 0] [Right5endTr|Default 0]                            *"
  echo "********************************************************************************************"
else

Data=$1
Metatable=$2
if [ ! -n "$3" ];then
    Pre=""
    OurpurPrefix="data"
    FeatureTablePrefix="table"
    RepSeq="rep_seqs"
    AlignedRepSeq="aligned_rep_seqs"
    Denoise="denoising_stats"
    Masked="masked_aligned_rep_seqs"
    UnrootTree="unrooted_tree"
    RootTree="rooted_tree"
else
    Pre=$3
    OurpurPrefix=${Pre}_data
    FeatureTablePrefix=${Pre}_table
    RepSeq=${Pre}_rep_seqs
    AlignedRepSeq=${Pre}_aligned_rep_seqs
    Denoise=${Pre}_denoising_stats
    Masked=${Pre}_masked_aligned_rep_seqs
    UnrootTree=${Pre}_unrooted_tree
    RootTree=${Pre}_rooted_tree
fi
if [ ! -n "$4" ];then
    LeftTr=270
else
    LeftTr=$4
fi
if [ ! -n "$5" ];then
    RightTr=250
else
    RightTr=$5
fi
if [ ! -n "$6" ];then
    Left5endTr=0
else
    Left5endTr=$6
fi
if [ ! -n "$7" ];then
    Right5endTr=0
else
    Right5endTr=$7
fi

  echo "**********************************************************************"
  echo "*     PipeQiime2Meta.sh: Pipeline for Qiime2 metagenomic analysis    *"
  echo "* Part 2 of the pipeline: DATA2, feature-table, alignment, phylogeny *"
  echo "**********************************************************************"
echo "Continuing Part 1....."

echo "5. Running DATA2 denoising"
echo "   Loading Qiime2"
module load qiime/2019.4
source activate qiime2-2019.4

echo "   Data Folder Name: "$Data
echo "   Output Data Prefix: "$OurpurPrefix
echo "   Left keep length: "$LeftTr
echo "   Right keep length: "$RightTr
echo "   Left trim length: "$Left5endTr
echo "   Right trim length: "$Right5endTr
echo "   This step takes long time..."
echo "   qiime dada2 denoise-paired --i-demultiplexed-seqs "${OurpurPrefix}.qza" --p-trunc-len-f "${LeftTr}" --p-trunc-len-r "${RightTr}" --p-trim-left-f "${Left5endTr}" --p-trim-left-r "${Right5endTr}" --o-table "${FeatureTablePrefix}.qza" --o-representative-sequences "${RepSeq}.qza" --o-denoising-stats "${Denoise}.qza" --verbose --p-n-threads 0"

qiime dada2 denoise-paired \
    --i-demultiplexed-seqs ${OurpurPrefix}.qza \
    --p-trim-left-f ${Left5endTr} \
    --p-trim-left-r ${Right5endTr} \
    --p-trunc-len-f ${LeftTr} \
    --p-trunc-len-r ${RightTr} \
    --o-table ${FeatureTablePrefix}.qza \
    --o-representative-sequences ${RepSeq}.qza \
    --o-denoising-stats ${Denoise}.qza \
    --verbose --p-n-threads 0
echo ""

echo "6. Summarizing Feature Table, with Metatable.csv file"
echo "   qiime feature-table summarize --i-table "${FeatureTablePrefix}.qza" --o-visualization "${FeatureTablePrefix}" --m-sample-metadata-file "${Metatable}
echo "   qiime feature-table tabulate-seqs --i-data "${RepSeq}.qza" --o-visualization "${RepSeq}
echo "   qiime metadata tabulate --m-input-file "${Denoise}.qza" --o-visualization "${Denoise}

qiime feature-table summarize --i-table ${FeatureTablePrefix}.qza --o-visualization ${FeatureTablePrefix} --m-sample-metadata-file ${Metatable}
qiime feature-table tabulate-seqs --i-data ${RepSeq}.qza --o-visualization ${RepSeq}
qiime metadata tabulate --m-input-file ${Denoise}.qza --o-visualization ${Denoise}
echo ""

echo "7. Alignment"
echo "   qiime alignment mafft --i-sequences "${RepSeq}.qza" --o-alignment "${AlignedRepSeq}
echo "   qiime alignment mask --i-alignment "${AlignedRepSeq}.qza" --o-masked-alignment "${Masked}.qza

qiime alignment mafft --i-sequences ${RepSeq}.qza --o-alignment ${AlignedRepSeq}
qiime alignment mask --i-alignment ${AlignedRepSeq}.qza --o-masked-alignment ${Masked}.qza
echo ""

echo "8. Phylogeny"
echo "   qiime phylogeny fasttree --i-alignment "${Masked}.qza" --o-tree "${UnrootTree}
echo "   qiime phylogeny midpoint-root --i-tree "${UnrootTree}.qza" --o-rooted-tree "${RootTree}

qiime phylogeny fasttree --i-alignment ${Masked}.qza --o-tree ${UnrootTree}
qiime phylogeny midpoint-root --i-tree ${UnrootTree}.qza --o-rooted-tree ${RootTree}
echo ""

echo "[Done Step 2 workflow]"
echo "   Output files: "${FeatureTablePrefix}.qza"/qzv, "${RepSeq}.qza"/qzv, "${Denoise}.qza"/qzv"
echo "   Output files: "${AlignedRepSeq}.qza", "${Masked}.qza
echo "   Output files: "${UnrootTree}.qza"/qzv, "${RootTree}.qza"/qzv"
echo "   Qiime2 visualization: https://view.qiime2.org/"

fi
