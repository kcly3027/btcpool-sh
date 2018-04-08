#启动gbtmaker
cd /work/btcpool/build/run_gbtmaker
./gbtmaker -c ./gbtmaker.cfg -l ./log_gbtmaker &

#启动jobmaker
cd /work/btcpool/build/run_jobmaker
./jobmaker -c ./jobmaker.cfg -l ./log_jobmaker &

#启动sserver
cd /work/btcpool/build/run_sserver
./sserver -c ./sserver.cfg -l ./log_sserver &

#启动blkmaker
cd /work/btcpool/build/run_blkmaker
./blkmaker -c ./blkmaker.cfg -l ./log_blkmaker &

#启动sharelogger
cd /work/btcpool/build/run_sharelogger
./sharelogger -c ./sharelogger.cfg -l ./log_sharelogger &

#启动slparser
cd /work/btcpool/build/run_slparser
./slparser -c ./slparser.cfg -l ./log_slparser &

#启动sharelogger
cd /work/btcpool/build/run_statshttpd
./statshttpd -c ./statshttpd.cfg -l ./log_statshttpd &

#启动poolwatcher 
cd /work/btcpool/build/run_poolwatcher 
./poolwatcher -c ./poolwatcher.cfg -l ./log_poolwatcher &