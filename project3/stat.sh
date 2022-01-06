runtime=$1
io_depth=$2
polling=$3
repetition=$6
output_folder="results/stat/repetition${repetition}/"
io_engine="io_uring"
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


#chck that cmd line params are set

LC='\033[1;36m'
NC='\033[0m' # no color
if [ $# -lt 3 ]
then 
	echo -e  "Need to pass following cmd line args: ${LC}runtime${NC}(in seconds), ${LC}io_engine${NC}(io_uring, libaio, sync), ${LC}polling${NC}(should io_uring poll cpu)"
	exit 1
fi

echo $repetition
#delete old and create new dir



echo $io_engine
#check if io_uring set as io_engine
using_io_uring=0; [ "$io_engine" == "io_uring" ] && using_io_uring=1

if [ $using_io_uring == 1 ] 
then
	sudo fio-3.28/./fio --name=randread --ioengine=$io_engine --iodepth=${io_depth} --rw=randread --bs=4k --direct=1 --size=1GB --runtime=$runtime --sqthread_poll=$polling | tee ${output_folder}fio_io_depth_${io_depth}.txt & 
else
	sudo fio-3.28/./fio --name=randread --ioengine=$io_engine --iodepth=${io_depth} --rw=randread --bs=4k --direct=1 --size=1G --runtime=$runtime | tee ${output_folder}fio_io_depth_${io_depth}.txt &
fi

fioPID=$!
sleep $perf_wait

perf stat &> >(tee ${output_folder}perf_io_depth_${io_depth}.txt) &
perfPID=$!
sleep $perf_dur

kill -2 $perfPID
wait $perfPID
wait $fioPID
