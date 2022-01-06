runtime=$1
io_engine=$2
polling=$3

if [[ -n "$4"  ]]
then
	perf_wait=$4

else
	perf_wait=0
fi


if [[ -n "$5"  ]]
then
	perf_dur=$5
else 
	perf_dur=$((runtime-perf_wait))
fi

echo $perf_dur
#chck that cmd line params are set

LC='\033[1;36m'
NC='\033[0m' # no color
if [ $# -lt 3 ]
then 
	echo -e  "Need to pass following cmd line args: ${LC}runtime${NC}(in seconds), ${LC}io_engine${NC}(io_uring, libaio, sync), ${LC}polling${NC}(should io_uring poll cpu)"
	exit 1
fi



#check if io_uring set as io_engine
using_io_uring=0; [ "$io_engine" == "io_uring" ] && using_io_uring=1

if [ $using_io_uring == 1 ] 
then
	sudo fio-3.28/./fio --name=randread --ioengine=$io_engine --iodepth=1 --rw=randread --bs=4k --direct=1 --size=1GB --runtime=$runtime --sqthread_poll=$polling &
else
	sudo fio-3.28/./fio --name=randread --ioengine=$io_engine --iodepth=1 --rw=randread --bs=4k --direct=1 --size=1G --runtime=$runtime &
fi

fioPID=$!
sleep $perf_wait

perf record -g &
perfPID=$!
sleep $perf_dur

kill -2 $perfPID
wait $perfPID
wait $fioPID
perf script | FlameGraph/./stackcollapse-perf.pl > out.perf-folded
FlameGraph/./flamegraph.pl out.perf-folded > perf.svg
