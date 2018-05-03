#!/bin/bash
#
# init install script for btcpool
#
# OS: Ubuntu 14.04 LTS
# 
# @copyright btc.com
# @author Kevin Pan
# @since 2016-08

# 初期准备工作
ufw disable
apt-get install openssh-server
service ssh start
cd /
mkdir sbtc_work
cd /sbtc_work
wget -O SuperBitcoin-0.16.2.tar.gz https://github.com/superbitcoin/SuperBitcoin/archive/v0.16.2.tar.gz
apt-get install unzip
tar zxf SuperBitcoin-0.16.2.tar.gz
rm -rf SuperBitcoin-0.16.2.tar.gz

# 正式开始
CPUS=`lscpu | grep '^CPU(s):' | awk '{print $2}'`

apt-get update
apt-get install -y build-essential autotools-dev libtool autoconf automake pkg-config cmake
apt-get install -y openssl libssl-dev libcurl4-openssl-dev libconfig++-dev libboost-all-dev libmysqlclient-dev libgmp-dev libzookeeper-mt-dev

apt-get update
apt-get install -y build-essential autotools-dev libtool autoconf automake pkg-config cmake \
                   openssl libssl-dev libcurl4-openssl-dev libconfig++-dev \
                   libboost-all-dev libgmp-dev libmysqlclient-dev libzookeeper-mt-dev \
                   libzmq3-dev libgoogle-glog-dev libevent-dev

# zmq-v4.1.5
mkdir -p /root/source && cd /root/source
wget https://github.com/zeromq/zeromq4-1/releases/download/v4.1.5/zeromq-4.1.5.tar.gz
tar zxvf zeromq-4.1.5.tar.gz
cd zeromq-4.1.5
./autogen.sh && ./configure && make -j $CPUS
make check && make install && ldconfig

# glog-v0.3.4
mkdir -p /root/source && cd /root/source
wget https://github.com/google/glog/archive/v0.3.4.tar.gz
tar zxvf v0.3.4.tar.gz
cd glog-0.3.4
./configure && make -j $CPUS && make install

# librdkafka-v0.9.1
apt-get install -y zlib1g zlib1g-dev
mkdir -p /root/source && cd /root/source
wget https://github.com/edenhill/librdkafka/archive/0.9.1.tar.gz
tar zxvf 0.9.1.tar.gz
cd librdkafka-0.9.1
./configure && make -j $CPUS && make install

# libevent-2.0.22-stable
mkdir -p /root/source && cd /root/source
wget https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
tar zxvf libevent-2.0.22-stable.tar.gz
cd libevent-2.0.22-stable
./configure
make -j $CPUS
make install

# btcpool
mkdir -p /sbtc_work && cd /sbtc_work
git clone https://github.com/btccom/btcpool.git
cd /sbtc_work/btcpool
mkdir build && cd build
cmake -DJOBS=$CPUS -DCMAKE_BUILD_TYPE=Release -DCHAIN_TYPE=SBTC -DCHAIN_SRC_ROOT=/sbtc_work/SuperBitcoin-0.16.2 ..
make -j $CPUS

#init folders
cd /sbtc_work/btcpool/build
bash ../install/init_folders.sh
#init kafka
cd /sbtc_work/kafka

# for Bitcoin or BitcoinCash mining
./bin/kafka-topics.sh --create --topic SBTC_RawGbt         --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
./bin/kafka-topics.sh --create --topic SBTC_StratumJob     --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1 
./bin/kafka-topics.sh --create --topic SBTC_SolvedShare    --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1 
./bin/kafka-topics.sh --create --topic SBTC_ShareLog       --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
./bin/kafka-topics.sh --create --topic SBTC_CommonEvents   --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
# for Namecoin merge-mining
./bin/kafka-topics.sh --create --topic SBTC_NMCAuxBlock    --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
./bin/kafka-topics.sh --create --topic SBTC_NMCSolvedShare --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
# for RSK merge-mining
./bin/kafka-topics.sh --create --topic SBTC_RawGw          --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
./bin/kafka-topics.sh --create --topic SBTC_RskSolvedShare --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1

# do not keep 'RawGbt' message more than 6 hours
./bin/kafka-configs.sh --zookeeper 127.0.0.1:2181 --alter --entity-type topics -entity-name SBTC_RawGbt       --add-config retention.ms=21600000
# 'CommonEvents': 12 hours
./bin/kafka-configs.sh --zookeeper 127.0.0.1:2181 --alter --entity-type topics -entity-name SBTC_CommonEvents --add-config retention.ms=43200000
# 'RawGw': 6 hours
#./bin/kafka-configs.sh --zookeeper 127.0.0.1:2181 --alter --entity-type topics -entity-name RawGw --add-config retention.ms=21600000
# show topics
./bin/kafka-topics.sh --describe --zookeeper 127.0.0.1:2181

# create database `bpool_local_db`, `bpool_local_stats_db`
# and import tables with mysql command-line client.
cd /sbtc_work/btcpool/install
mysql -h xxx -u xxx -p
CREATE DATABASE bpool_local_db;
USE bpool_local_db;
SOURCE bpool_local_db.sql;

CREATE DATABASE bpool_local_stats_db;
USE bpool_local_stats_db;
SOURCE bpool_local_stats_db.sql;


#启动gbtmaker
#配置gbtmaker
cd /sbtc_work/btcpool/build/run_gbtmaker
./gbtmaker -c ./gbtmaker.cfg -l ./log_gbtmaker &
tail -f log_gbtmaker/gbtmaker.INFO

#启动jobmaker
#配置jobmaker
cd /sbtc_work/btcpool/build/run_jobmaker
./jobmaker -c ./jobmaker.cfg -l ./log_jobmaker &
tail -f log_jobmaker/jobmaker.INFO

#启动sserver
#配置sserver
cd /sbtc_work/btcpool/build/run_sserver
./sserver -c ./sserver.cfg -l ./log_sserver &
tail -f log_sserver/sserver.INFO 

#启动blkmaker
#配置blkmaker
cd /sbtc_work/btcpool/build/run_blkmaker
./blkmaker -c ./blkmaker.cfg -l ./log_blkmaker &
tail -f log_blkmaker/blkmaker.INFO

#启动sharelogger
#配置sharelogger
cd /sbtc_work/btcpool/build/run_sharelogger
./sharelogger -c ./sharelogger.cfg -l ./log_sharelogger &
#tail -f log_sharelogger/sharelogger.INFO

#启动slparser
#配置slparser
cd /sbtc_work/btcpool/build/run_slparser
./slparser -c ./slparser.cfg -l ./log_slparser &

#启动sharelogger
#配置sharelogger
cd /sbtc_work/btcpool/build/run_statshttpd
./statshttpd -c ./statshttpd.cfg -l ./log_statshttpd &

#启动poolwatcher 
#配置poolwatcher 
cd /sbtc_work/btcpool/build/run_poolwatcher 
./poolwatcher -c ./poolwatcher.cfg -l ./log_poolwatcher &




#安装cgminer
cd /sbtc_work/
apt-get -y install build-essential autoconf automake libtool pkg-config libcurl3-dev libudev-dev
apt-get -y install libusb-1.0-0-dev
git clone https://github.com/ckolivas/cgminer.git
cd cgminer
sh autogen.sh
./configure --enable-cpumining --disable-opencl
make

#cgminer测试
./cgminer -o stratum+tcp://127.0.0.1:3333 -u ly001.01

./cgminer --cpu-threads 3 --url 127.0.0.1:3333 --userpass ly001.01:
#./cgminer -o stratum+tcp://127.0.0.1:3333 -u jack -p x --debug --protocol-dump
#--debug，调试模式
#--protocol-dump，协议输出


vi /sbtc_work/btcpool/build/run_gbtmaker/gbtmaker.cfg
vi /sbtc_work/btcpool/build/run_jobmaker/jobmaker.cfg
vi /sbtc_work/btcpool/build/run_sserver/sserver.cfg
vi /sbtc_work/btcpool/build/run_blkmaker/blkmaker.cfg
vi /sbtc_work/btcpool/build/run_sharelogger/sharelogger.cfg
vi /sbtc_work/btcpool/build/run_slparser/slparser.cfg
vi /sbtc_work/btcpool/build/run_statshttpd/statshttpd.cfg
vi /sbtc_work/btcpool/build/run_poolwatcher/poolwatcher.cfg
