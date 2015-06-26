#!/bin/bash

#FOLDERS
hbase_folder=$1

#PARAMETERS
hbase_v=$2

#CONFIGURATION FILES
hbase_site="${hbase_folder}/conf/hbase-site.xml"
hbase_env="${hbase_folder}/conf/hbase-env.sh"
slaves="${hbase_folder}/conf/regionservers"

#LINKS
hbase_link="archive.apache.org/dist/hbase/hbase-${hbase_v}/hbase-${hbase_v}-hadoop2-bin.tar.gz"

wget -nc ${hbase_link}
echo "HBase Downloaded!!"
tar -xf hbase-${hbase_v}-hadoop2-bin.tar.gz
mv hbase-${hbase_v}-hadoop2 ${hbase_folder}

cp conf/hbase/hbase-site.xml ${hbase_site}
cp conf/hbase/hbase-env.sh ${hbase_env}
cp conf/hbase/regionservers ${slaves}

echo HBase configured!
