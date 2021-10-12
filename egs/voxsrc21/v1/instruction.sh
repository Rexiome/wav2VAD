#!/bin/bash
#copyright wangjie xmuspeech 2021.10.9
#perform wav2VAD on voxSRC-21 set

INSTRUCTION=$1
SET=$2
exp_dir=$3 # output experiment directory
data_dir=$4
vad_dir=$5
scores_path=$6
config_path=$7 #config file directory
echo "$config_path"
source ./$config_path
echo "config_path=$config_path"
if [[ $INSTRUCTION = "prepare_train" ]]; then
	echo "prepare train files"
fi

if [[ $INSTRUCTION = "train_ASR" ]]; then
	echo "train ASR"
fi

if [[ $INSTRUCTION = "decode_ASR" ]]; then
	echo "decode ASR"
fi

if [[ $INSTRUCTION = "binarizer" ]]; then
	echo "apply binarizer"
	
	vad_result=$vad_dir/result
	
	if [ ! -d $vad_result ];then
		mkdir -p $vad_result
	fi
	
	python local/ASR_VAD.py --onset $onset --offset $offset --min_duration_on $mdon \
		--min_duration_off $mdof --integral_frames $integral_frames $scores_path $vad_dir 
	
fi

if [[ $INSTRUCTION = "binarizer_gridSearch" ]]; then
	echo "perform hpyer-parmeter grid search on binarizer"

	vad_result=$vad_dir/result
	
	if [[ $SET = "dev" ]];then
		dataset_type=development
	else
		"test set has not reference rttm"
	fi
	
	./local/vad_gridSearch.sh --start 0.005 --end 0.2 --step 0.01 $scores_path $data_dir/$SET/ref.rttm $vad_result $vad_dir $config_path

fi

if [[ $INSTRUCTION = "score" ]]; then
	if [[ $SET = "dev" ]]; then
		cat $vad_dir/rttm/* > $vad_dir/result/sys.rttm
		score_vad.sh --ref $data_dir/$SET/ref.rttm --sys $vad_dir/result/sys.rttm > \
			$vad_dir/result/metrics.txt
		cat $vad_dir/result/metrics.txt
	else
		echo "Can only be used on development sets "
	fi
fi

