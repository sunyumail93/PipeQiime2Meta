#!/usr/bin/env bash
#PipeQiime2Meta_Prepare.sh
#Run this after downloading the scripts. The desired files will be downloaded and copied to /bin
#Version: Yu H. Sun, 2020-04-30

#This pipeline requires two files in the PipelineHomeDir/bin directory:
#-rwx------+ 1 root root 504M Jan 10 18:04 silva_132_99_16S.fna
#-rwx------+ 1 root root  58M Jan 10 18:10 taxonomy_7_levels.txt

#Those two files can be downloaded from SILVA32 database:
if [ ! -n "$1" ];then
  echo "********************************************************************************"
  echo "*                   Welcome to use PipeQiime2Meta_Prepare.sh                   *"
  echo "*This script prepares the two critical files for the pipeline                  *"
  echo "*Please run this script at the directory with other scripts (Step 1-3) together*"
  echo "*It will create a /bin folder with two files in                                *"
  echo "*[Usage]: PipeQiime2Meta_Prepare.sh [Anything_not_empty]                       *"
  echo "********************************************************************************"
else
echo "Start runnning PipeQiime2Meta_Prepare.sh to prepare files under /bin directory..."
echo "This will take a few minutes..."
rm -rf Silva_132_release.zip
wget "https://www.arb-silva.de/fileadmin/silva_databases/qiime/Silva_132_release.zip"

#Unzip
unzip Silva_132_release.zip

#PATH to the two files:
if [ ! -d bin ];then mkdir bin;fi
cp SILVA_132_QIIME_release/rep_set/rep_set_16S_only/99/silva_132_99_16S.fna ./bin
cp SILVA_132_QIIME_release/taxonomy/16S_only/99/taxonomy_7_levels.txt ./bin

if [[ -s ./bin/silva_132_99_16S.fna && -s ./bin/taxonomy_7_levels.txt ]];then
        echo "Successful!"
        echo "Cleaning..."
	rm -rf Silva_132_release.zip Silva_132_release SILVA_132_QIIME_release __MACOSX
	echo "Done"
else
	echo "Error occurred"
	echo "Cleaning..."
	rm -rf Silva_132_release.zip Silva_132_release __MACOSX SILVA_132_QIIME_release
fi
fi
