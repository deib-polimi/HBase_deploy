#!/bin/bash

#TOOL INPUTS
namenode="tool/input/hadoop_namenodes"
slave="tool/input/slaves"
secnamenode="tool/input/hadoop_secondarynamenode"
master="tool/input/hbase_masters"
replications="tool/input/replication"
download="tool/input/download"
replication=$(sed -n "1p" ${replications})

#FOLDERS
hadoop_folder=$1
hadoop_data=${hadoop_folder}/$2
hbase_folder=$3
java_path="/usr/lib/jvm/java-6-openjdk-amd64"

#FILE LENGHTS
master_num=$(wc -l < ${master})
secnamenode_num=$(wc -l < ${secnamenode})
slave_num=$(wc -l < ${slave})

#TOOL HADOOP AND HBASE
hadoop_site="tool/conf/hadoop/core-site.xml"
hadoop_env="tool/conf/hadoop/hadoop-env.sh"
hadoop_hdfs="tool/conf/hadoop/hdfs-site.xml"
hadoop_masters="tool/conf/hadoop/masters"
hadoop_slaves="tool/conf/hadoop/slaves"
hbase_site="tool/conf/hbase/hbase-site.xml"
hbase_env="tool/conf/hbase/hbase-env.sh"
hbase_slaves="tool/conf/hbase/regionservers"

#PARAMETERS
namenode_port=9000
master_port=54310
zk_port=2181

#
cp ${slave} ${hbase_slaves}

for ((X=1; X<=${slave_num}; X++))
do
  address=$(sed -n "${X}p" ${hbase_slaves})
  index=$(expr index ${address} @)
  ip=${address:index}
  sed -i ${X}s/.*/${ip}/ ${hbase_slaves}
done

cp ${hbase_slaves} ${hadoop_slaves}
cp ${secnamenode} ${hadoop_masters}

for ((X=1; X<=${secnamenode_num}; X++))
do
  address=$(sed -n "${X}p" ${hadoop_masters})
  index=$(expr index ${address} @)
  ip=${address:index}
  sed -i ${X}s/.*/${ip}/ ${hadoop_masters}
done

temp=$(sed -n "1p" ${namenode})
index=$(expr index ${temp} @)
ip_namenode=${temp:index}


cp tool/hadoop_conf/core-site.xml ${hadoop_site}
cp tool/hadoop_conf/hadoop-env.sh ${hadoop_env}
cp tool/hadoop_conf/hdfs-site.xml ${hadoop_hdfs}

sed -i s/NAMENODE/${ip_namenode}/g ${hadoop_site}
sed -i s/PORT/${namenode_port}/g ${hadoop_site}
sed -i s+HADOOP_DATA_DIR+${hadoop_data}+g ${hadoop_site}
sed -i s/REPLICATION/${replication}/g ${hadoop_hdfs}
sed -i s+JAVA_HOME+JAVA_HOME=${java_path}+g ${hadoop_env}

temp=$(sed -n "1p" ${master})
index=$(expr index ${temp} @)
ip_master=${temp:index}

cp tool/hbase_conf/hbase-site.xml ${hbase_site}
cp tool/hbase_conf/hbase-env.sh ${hbase_env}

sed -i s/MASTER/${ip_master}/g ${hbase_site}
sed -i s/HOST_PORT/${master_port}/g ${hbase_site}
sed -i s/NAMENODE/${ip_namenode}/g ${hbase_site}
sed -i s/NN_PORT/${namenode_port}/g ${hbase_site}
sed -i s/HB_FOLDER/${hbase_folder}/g ${hbase_site}
sed -i s/ZK_PORT/${zk_port}/g ${hbase_site}
sed -i s+JAVA_HOME+JAVA_HOME=${java_path}+g ${hbase_env}

