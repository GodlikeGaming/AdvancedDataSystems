runtime=$1
declare -a arr=("libaio" "sync" "io_uring" "io_uring")

i=0
for str in ${arr[@]}
do
	echo $i
	if (( i < 3 )) 
	then
		./record.sh $runtime $str 0
	else 
		./record.sh $runtime $str 1	
		str="${str}_polling"
	fi
	((i=i+1))
	
	# move perf.svg
	mv perf.svg results/record/$str.svg
done


