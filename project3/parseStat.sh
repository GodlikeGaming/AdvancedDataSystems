
echo "repetition, io_depth, avg_clat, 99th percentile, bandwith, context_switches, page_faults, cpu_migrations"
for d in results/stat/*/ ; 
do
for io_depth in 1 2 4 8
do
	filename="${d}fio_io_depth_${io_depth}.txt"
	# PARSE FIO
#	echo $(awk '{for (I=1;I<NF;I++) if ($I == "avg=468.19") print $(I+1)}' $filename)	
#	awk -F 'avg=' '{print $2}' $filename | awk '{print $1}'
	avg_clat=$(grep -hnr "clat (usec):" $filename | awk -F 'avg=' '{print $2}' | awk '{print $1}' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
#echo $out

	percentile_99=$(grep -hnr "99.00th" $filename | awk -F '99.00th=\[' '{print $2}' | awk '{print $1}' | grep -Eo '[+-]?[0-9]+([.][0-9]+)?')
	
	bandwidth=$(grep -hnr "read: IOPS" $filename | awk -F 'BW=' '{print $2}' | awk '{print $1}')


	# PARSE PERF

	filename="${d}perf_io_depth_${io_depth}.txt"

	context_switches=$(grep -hnr "context-switches" $filename | awk '{print $2}' )	
	page_faults=$(grep -hnr "page-faults" $filename | awk '{print $2}' )
	cpu_migrations=$(grep -hnr "cpu-migrations" $filename | awk '{print $2}' )

	echo "${d},${io_depth},${avg_clat},${percentile_99},${bandwidth},${context_switches},${page_faults},${cpu_migrations}"		
done
done



