runtime=$1
perf_delay=$2
perf_dur=$3
reps=$4

for repetition in $( seq 1 $reps )
do
	rm -rf "results/stat/repetition${repetition}/"	
	mkdir "results/stat/repetition${repetition}/"
	for io_depth in 1 2 4 8
	do
		echo "${repetition}: io_depth:${io_depth}" 
		./stat.sh $runtime $io_depth 0 $perf_delay $perf_dur $repetition
		wait $!
	done
done



