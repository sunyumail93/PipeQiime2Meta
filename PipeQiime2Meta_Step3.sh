#!/usr/bin/env bash
#PipeQiime2Meta_Step3.sh
#This is a pipeline for Qiime2 metagenomic analysis, part 3
#Version: Yu H. Sun, 2020-01-10

if [ ! -n "$1" ]
then
  echo "********************************************************************************************"
  echo "*                PipeQiime2Meta.sh: Pipeline for Qiime2 metagenomic analysis               *"
  echo "*Part 3 of the pipeline: Diversity analysis, Rarefaction, Taxonomy bar plot                *"
  echo "*Make sure the OutputPrefix must be same as the one in Step 1 and 2, default = data        *"
  echo "*SamplingDepth is the lowest number of non-chimeric reads, or the samples will be dropped  *"
  echo "*Put SILVA32 16S files under Pipeline Home Directory/bin                                   *"
  echo "*  SILVA32: silva_132_99_16S.fna, taxonomy_7_levels.txt                                    *"
  echo "*Usage: `basename $0` [MetaTable.csv|Required] [SamplingDepth|Lowest non-chim]   *" 
  echo "*      [F primer|e.g.GTTYGATYMTGGCTCAG] [R primer|GCWGCCWCCCGTAGGWGT]                      *"
  echo "*      Optional: [OuputPrefix|NA: no prefix] [Plotting Steps|Default 25]                   *"
  echo "********************************************************************************************"
else

HomeDir=$(dirname `readlink -f $0`)
SILVA32_16S=${HomeDir}/bin/silva_132_99_16S.fna
Taxonomy=${HomeDir}/bin/taxonomy_7_levels.txt
Metatable=$1
SamplingDepth=$2
F_Primer=$3
R_Primer=$4
if [ ! -n "$5" ];then
    Pre=""
    OurpurPrefix="data"
    FeatureTablePrefix="table"
    RepSeq="rep_seqs"
    AlignedRepSeq="aligned_rep_seqs"
    Denoise="denoising_stats"
    Masked="masked_aligned_rep_seqs"
    UnrootTree="unrooted_tree"
    RootTree="rooted_tree"
    CoreResults="core_metrics_results"
    RareFaction="alpha_rarefaction"
    SILVA32_16S_Import="silva32"
    Taxonomy_Import="taxonomy_ref"
    ReferenceSeq="ref_seqs"
    Classifier="classifier"
    TaxonomyResult="taxonomy"
    TaxaBarPlots="taxa_bar_plots"
else
    Pre=$5
    if [ "$5" == "NA" ];then
      OurpurPrefix="data"
      FeatureTablePrefix="table"
      RepSeq="rep_seqs"
      AlignedRepSeq="aligned_rep_seqs"
      Denoise="denoising_stats"
      Masked="masked_aligned_rep_seqs"
      UnrootTree="unrooted_tree"
      RootTree="rooted_tree"
      CoreResults="core_metrics_results"
      RareFaction="alpha_rarefaction"
      SILVA32_16S_Import="silva32"
      Taxonomy_Import="taxonomy"
      ReferenceSeq="ref_seqs"
      Classifier="classifier"
      TaxonomyResult="taxonomy"
      TaxaBarPlots="taxa_bar_plots"
    fi
    OurpurPrefix=${Pre}_data
    FeatureTablePrefix=${Pre}_table
    RepSeq=${Pre}_rep_seqs
    AlignedRepSeq=${Pre}_aligned_rep_seqs
    Denoise=${Pre}_denoising_stats
    Masked=${Pre}_masked_aligned_rep_seqs
    UnrootTree=${Pre}_unrooted_tree
    RootTree=${Pre}_rooted_tree
    CoreResults=${Pre}_core_metrics_results
    RareFaction=${Pre}_alpha_rarefaction
    SILVA32_16S_Import=${Pre}_silva32
    Taxonomy_Import=${Pre}_taxonomy_ref
    ReferenceSeq=${Pre}_ref_seqs
    Classifier=${Pre}_classifier
    TaxonomyResult=${Pre}_taxonomy
    TaxaBarPlots=${Pre}_taxa_bar_plots
fi
if [ ! -n "$6" ];then
    Steps=25
else
    Steps=$6
fi

  echo "**********************************************************************"
  echo "*     PipeQiime2Meta.sh: Pipeline for Qiime2 metagenomic analysis    *"
  echo "* Part 3 of the pipeline: DATA2, feature-table, alignment, phylogeny *"
  echo "**********************************************************************"
echo "Continuing Part 2....."

echo "9. Diversity core analysis"
echo "   Loading Qiime2"
module load qiime/2019.4
source activate qiime2-2019.4

echo "   Output Data Prefix: "$OurpurPrefix
echo "   Metadata File: "$Metatable
echo "   Sampling Depth: "$SamplingDepth
echo "   Primer F: "$F_Primer
echo "   Primer R: "$R_Primer
echo "   qiime diversity core-metrics-phylogenetic --i-phylogeny "${RootTree}.qza" --i-table "${FeatureTablePrefix}.qza" --p-sampling-depth "${SamplingDepth}" --m-metadata-file "$Metatable" --output-dir "${CoreResults}

qiime diversity core-metrics-phylogenetic \
    --i-phylogeny ${RootTree}.qza \
    --i-table ${FeatureTablePrefix}.qza \
    --p-sampling-depth ${SamplingDepth} \
    --m-metadata-file ${Metatable} \
    --output-dir ${CoreResults}
echo ""

echo "10. Alpha diversity analysis visualization"
echo "   qiime diversity alpha-group-significance --i-alpha-diversity "${CoreResults}"/faith_pd_vector.qza --m-metadata-file "${Metatable}" --o-visualization "${CoreResults}"/faith_pd_group_significance"

qiime diversity alpha-group-significance \
    --i-alpha-diversity ${CoreResults}/faith_pd_vector.qza \
    --m-metadata-file ${Metatable} \
    --o-visualization ${CoreResults}/faith_pd_group_significance
echo ""

echo "11. Alpha rarefaction plots: plateau plot"
echo "   qiime diversity alpha-rarefaction --i-table "${CoreResults}"/rarefied_table.qza --p-max-depth "${SamplingDepth}" --m-metadata-file "${Metatable}" --p-steps "${Steps}" --o-visualization "${RareFaction}.qzv

qiime diversity alpha-rarefaction \
    --i-table ${CoreResults}/rarefied_table.qza \
    --p-max-depth ${SamplingDepth} \
    --m-metadata-file ${Metatable} \
    --p-steps ${Steps} \
    --o-visualization ${RareFaction}.qzv
echo ""

echo "12. Import 16S and taxonomy data from SILVA32_99"
echo "   qiime tools import --type 'FeatureData[Sequence]' --input-path "${SILVA32_16S}" --output-path "${SILVA32_16S_Import}
echo "   qiime tools import --type 'FeatureData[Taxonomy]' --input-path "${Taxonomy}" --input-format HeaderlessTSVTaxonomyFormat --output-path "${Taxonomy_Import}  #HeaderlessTSVTaxonomyFormat option is required for SILVA32 file
qiime tools import --type 'FeatureData[Sequence]' --input-path ${SILVA32_16S} --output-path ${SILVA32_16S_Import}
qiime tools import --type 'FeatureData[Taxonomy]' --input-path ${Taxonomy} --input-format HeaderlessTSVTaxonomyFormat --output-path ${Taxonomy_Import}
echo ""

echo "13. Extract reads and train the classifier"
echo "   This step is time consuming"
echo "   qiime feature-classifier extract-reads --i-sequences "${SILVA32_16S_Import}.qza" --p-f-primer "${F_Primer}" --p-r-primer "${R_Primer}" --p-trunc-len 300 --o-reads "${ReferenceSeq}
qiime feature-classifier extract-reads \
    --i-sequences ${SILVA32_16S_Import}.qza \
    --p-f-primer ${F_Primer} \
    --p-r-primer ${R_Primer} \
    --p-trunc-len 300 \
    --o-reads ${ReferenceSeq}

echo "   This step is also time consuming"
echo "   qiime feature-classifier fit-classifier-naive-bayes --i-reference-reads "${ReferenceSeq}.qza" --i-reference-taxonomy "${Taxonomy_Import}.qza" --o-classifier "${Classifier}.qza
qiime feature-classifier fit-classifier-naive-bayes \
    --i-reference-reads ${ReferenceSeq}.qza \
    --i-reference-taxonomy ${Taxonomy_Import}.qza \
    --o-classifier ${Classifier}.qza
echo ""

echo "14. Assign taxonomy"
echo "   qiime feature-classifier classify-sklearn --i-classifier "${Classifier}.qza" --i-reads "${RepSeq}.qza" --o-classification "${TaxonomyResult}.qza
echo "   qiime metadata tabulate --m-input-file "${TaxonomyResult}.qza" --o-visualization "${TaxonomyResult}
qiime feature-classifier classify-sklearn \
    --i-classifier ${Classifier}.qza \
    --i-reads ${RepSeq}.qza \
    --o-classification ${TaxonomyResult}.qza

qiime metadata tabulate --m-input-file ${TaxonomyResult}.qza --o-visualization ${TaxonomyResult}
echo ""

echo "15. Bar plot with taxonomy, after classification"
echo "   qiime taxa barplot --i-table "${CoreResults}"/rarefied_table.qza --i-taxonomy "${TaxonomyResult}.qza" --m-metadata-file "${Metatable}" --o-visualization "${TaxaBarPlots}
qiime taxa barplot --i-table ${CoreResults}/rarefied_table.qza --i-taxonomy ${TaxonomyResult}.qza --m-metadata-file ${Metatable} --o-visualization ${TaxaBarPlots}

echo "[Done Step 3 workflow]"
echo "   Output folder: "${CoreResults}
echo "   Output files: "${RareFaction}.qzv", "${ReferenceSeq}", "${Classifier}.qza
echo "   Output files: "${TaxonomyResult}.qza", "${TaxaBarPlots}.qzv
echo "   Qiime2 visualization: https://view.qiime2.org/"

fi
