#!/bin/bash

cd ../

#MY FILES
hadoop="hadoop"
hbase="hbase"
hadoop_data="hadoop-datastore"
version="tool/input/download"
master="tool/input/hbase_masters"
namenode="tool/input/hadoop_namenodes"
secnamenode="tool/input/hadoop_secondarynamenode"
slave="tool/input/slaves"
links="tool/input/download"

#FILE LENGHTS
master_num=$(wc -l < ${master})
namenode_num=$(wc -l < ${namenode})
secnamenode_num=$(wc -l < ${secnamenode})
slave_num=$(wc -l < ${slave})

hadoop_v=$(sed -n "2p" ${links})
hbase_v=$(sed -n "4p" ${links})

echo -n "Java 7 is required on all machines. "
echo -n "Do you want to install Java? (y/n)"
read var
if [ ${var} = "n" ]; then
   exit 0
fi

source tool/configuration.sh ${hadoop} ${hadoop_data} ${hbase}

#CONFIGURATION
for ((X=1; X<=${secnamenode_num}; X++))
do
  secname_temp=$(sed -n "${X}p" ${secnamenode})
  echo Secondary Namenode n${X} : ${secname_temp}
  scp -qr tool/conf ${secname_temp}:~/
  echo conf copied in ${secname_temp}
  ssh ${secname_temp} sudo apt-get update
  ssh ${secname_temp} sudo apt-get install openjdk-7-jre
  ssh -t -t ${secname_temp} ./conf/hadoop_conf.sh ${hadoop} ${hadoop_data} ${hadoop_v}
  echo Hadoop configured in ${secname_temp}
  #HADOOP
done


echo "Secondary Namenode done!!"

for ((X=1; X<=${namenode_num}; X++))
do
  name_temp=$(sed -n "${X}p" ${namenode})
  echo Namenode n${X} : ${name_temp}
  scp -qr tool/conf ${name_temp}:~/
  echo conf copied in ${name_temp}
  ssh ${name_temp} sudo apt-get update
  ssh ${name_temp} sudo apt-get install openjdk-7-jre
  ssh -t -t ${name_temp} ./conf/hadoop_conf.sh ${hadoop} ${hadoop_data} ${hadoop_v}
  echo Hadoop configured in ${name_temp}
  #HADOOP
done


for ((X=1; X<=${master_num}; X++))
do
  master_temp=$(sed -n "${X}p" ${master})
  echo Master n${X} : ${master_temp}
  scp -qr tool/conf/ ${master_temp}:~/
  echo conf copied in ${master_temp}
  ssh ${master_temp} sudo apt-get update
  ssh ${master_temp} sudo apt-get install openjdk-7-jre
  ssh -t -t ${master_temp} ./conf/hbase_conf.sh ${hbase} ${hbase_v}
  echo HBase configured in ${master_temp}
done

for ((X=1; X<=${slave_num}; X++))
do
  slave_temp=$(sed -n "${X}p" ${slave})
  echo Slave n${X} : ${slave_temp}
  scp -rq tool/conf/ ${slave_temp}:~/
  echo conf copied in ${slave_temp}
  ssh ${slave_temp} sudo apt-get update
  ssh ${slave_temp} sudo apt-get install openjdk-7-jre
  ssh -t -t ${slave_temp} ./conf/hadoop_conf.sh ${hadoop} ${hadoop_data} ${hadoop_v}
  echo Hadoop configured in ${slave_temp}
  ssh -t -t ${slave_temp} ./conf/hbase_conf.sh ${hbase} ${hbase_v}
  echo HBase configured in ${slave_temp}
  #HADOOP + HBASE
done

#namenode format
first_namenode=$(sed -n "1p" ${namenode})
echo ${first_namenode}
ssh ${first_namenode} ./${hadoop}/bin/hadoop namenode -format
echo Hadoop namenode formatted!!

#imposto il namenode
hadoop_v=$(sed -n "2p" ${version})
if [ ${hadoop_v:0:1} = "1" ]
then 
   hadoop_bin="bin"
else
   hadoop_bin="sbin"
fi

ssh  ${first_namenode} ./${hadoop}/${hadoop_bin}/start-dfs.sh
echo Hadoop namenode setted!!

#imposto il master
first_master=$(sed -n "1p" ${master})
ssh  ${first_master} ./${hbase}/bin/start-hbase.sh
echo HBase first master setted!!

#backup masters
for ((X=2; X<=${master_num}; X++))
do
  master_temp=$(sed -n "${X}p" ${master})
  ssh ${master_temp} ./${hbase}/bin/hbase-daemon.sh start master
  echo HBase second master configured in ${master_temp}
done


echo finished!

exit 0

