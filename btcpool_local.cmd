cd /D F:\BtcPool\zookeeper-3.4.9\bin
zkServer.cmd

cd /D F:\BtcPool\kafka_2.11-1.1.0\bin\windows
kafka-server-start.bat ../../config/server.properties

cd /D F:\BtcPool\kafka_2.11-1.1.0\bin\windows
kafka-topics.bat --create --topic RawGbt         --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic StratumJob     --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic SolvedShare    --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic ShareLog       --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic CommonEvents   --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic NMCAuxBlock    --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic NMCSolvedShare --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic RawGw          --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-topics.bat --create --topic RskSolvedShare --zookeeper 127.0.0.1:2181 --replication-factor 1 --partitions 1
kafka-configs.bat --zookeeper 127.0.0.1:2181 --alter --entity-type topics -entity-name RawGbt       --add-config retention.ms=21600000
kafka-configs.bat --zookeeper 127.0.0.1:2181 --alter --entity-type topics -entity-name CommonEvents --add-config retention.ms=43200000
kafka-configs.bat --zookeeper 127.0.0.1:2181 --alter --entity-type topics -entity-name RawGw --add-config retention.ms=21600000
# show topics
kafka-topics.bat --describe --zookeeper 127.0.0.1:2181


cgminer --cpu-threads 3 -o stratum+tcp://192.168.42.136:3333 -u kcly3027 -p liuyang3027

 -o stratum+tcp://矿池地址及端口 -u 钱包地址

 -o stratum+tcp://47.104.193.93:3333 -u ly002.001 -t 2 

#http://47.104.193.93:8080/worker_status?user_id=111110&worker_id=3257201177373013563
#http://47.104.193.93:8080/ statshttpd
#http://47.104.193.93:8081/ slparser
#http://47.104.193.93:8081/share_stats?user_id=111110&worker_id=3257201177373013563&hour=2018041006