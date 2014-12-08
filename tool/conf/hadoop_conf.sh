#!/bin/bash

#PARAMETERS
hadoop_v=$3

#FOLDERS
hadoop_folder=$1
hadoop_data=$2

if [ ${hadoop_v:0:1} = 1 ]
then 
   hadoop_conf="conf"
else
   hadoop_conf="etc/hadoop"
fi

#CONFIGURATION FILES
core_site="${hadoop_folder}/${hadoop_conf}/core-site.xml"
hadoop_env="${hadoop_folder}/${hadoop_conf}/hadoop-env.sh"
hdfs_site="${hadoop_folder}/${hadoop_conf}/hdfs-site.xml"
master="${hadoop_folder}/${hadoop_conf}/masters"
slaves="${hadoop_folder}/${hadoop_conf}/slaves"

#LINKS
hadoop_link="apache.fis.uniroma2.it/hadoop/core/hadoop-${hadoop_v}/hadoop-${hadoop_v}.tar.gz"

wget -nc ${hadoop_link}
echo "Hadoop downloaded!!"
tar -xf hadoop-${hadoop_v}.tar.gz
mv hadoop-${hadoop_v} ${hadoop_folder}
mkdir ${hadoop_data}
chmod -R 777 ${hadoop_folder}

cp conf/hadoop/core-site.xml ${core_site}
cp conf/hadoop/hadoop-env.sh ${hadoop_env}
cp conf/hadoop/hdfs-site.xml ${hdfs_site}
cp conf/hadoop/masters ${master}
cp conf/hadoop/slaves ${slaves}

sed -i s+CURRENT_POS+$PWD+g ${core_site}

echo "Hadoop configured!"

exit 0
