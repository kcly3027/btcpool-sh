#启动gbtmaker
cd /work/btcpool/build/run_gbtmaker
nohup ./gbtmaker -c ./gbtmaker.cfg -l ./log_gbtmaker  > /dev/null &

#启动jobmaker
cd /work/btcpool/build/run_jobmaker
nohup ./jobmaker -c ./jobmaker.cfg -l ./log_jobmaker  > /dev/null &

#启动sserver
cd /work/btcpool/build/run_sserver
nohup ./sserver -c ./sserver.cfg -l ./log_sserver  > /dev/null &

#启动blkmaker
cd /work/btcpool/build/run_blkmaker
nohup ./blkmaker -c ./blkmaker.cfg -l ./log_blkmaker  > /dev/null &

#启动sharelogger
cd /work/btcpool/build/run_sharelogger
nohup ./sharelogger -c ./sharelogger.cfg -l ./log_sharelogger  > /dev/null &

#启动slparser
cd /work/btcpool/build/run_slparser
nohup ./slparser -c ./slparser.cfg -l ./log_slparser  > /dev/null &

#启动sharelogger
cd /work/btcpool/build/run_statshttpd
nohup ./statshttpd -c ./statshttpd.cfg -l ./log_statshttpd  > /dev/null &

#启动poolwatcher 
cd /work/btcpool/build/run_poolwatcher 
nohup ./poolwatcher -c ./poolwatcher.cfg -l ./log_poolwatcher  > /dev/null &