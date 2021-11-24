#copyright wangjie xmuspeech
#2021.10.9
start=
end=
step=
source parse_options.sh
scores_path=$1
ref_path=$2
vad_result=$3
vad_dir=$4
config_DIR=$5

set -e
source ./$config_DIR
if [ ! -d $vad_result ];then
	mkdir -p $vad_result
fi
echo "start=$start scores_path=$scores_path"
echo "onset offset detection error rate    accuracy    precision    recall     total    false alarm       %    miss     %" > \
	$vad_result/gridSearch_result.txt
best_DetER=100
best_onset=0
best_offset=0
for onset in `seq $start $step $end`; do
	for offset in `seq $start $step $end`; do
		python ./local/ASR_VAD.py --onset $onset --offset $offset --min_duration_on $mdon \
			--min_duration_off $mdof --integral_frames $integral_frames $scores_path $vad_dir 
		cat $vad_dir/rttm/* > $vad_dir/result/vad_on${onset}_off${offset}.rttm

		score_vad.sh --ref $ref_path --sys $vad_dir/result/vad_on${onset}_off${offset}.rttm > \
			$vad_dir/result/vad_on${onset}_off${offset}_metrics.txt
		
		performance_str=`cat $vad_result/vad_on${onset}_off${offset}_metrics.txt | grep TOTAL | sed s/TOTAL[[:space:]]*//g`
		echo "$onset	$offset				$performance_str" >> $vad_result/gridSearch_result.txt
		DetER=`echo $performance_str | awk '{print $1}'`
		if [ $(perl -e "print ($DetER < $best_DetER ? 1 : 0);") -eq 1 ]; then
			best_DetER=$DetER
			best_onset=$onset
			best_offset=$offset
		fi
		echo "DetER=$DetER"
		echo "best_DetER=$best_DetER"
	done
done

echo "onset$best_onset offset$best_offset best_DetEr=$best_DetER" >> $vad_result/gridSearch_result.txt
		
	

















