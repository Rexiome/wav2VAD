#!/bin/bash
#copyright wangjie xmuspeech 2021.10.9
#perform wav2VAD on voxSRC-21 set

INSTRUCTION=$1
SET=$2
exp_dir=$3 # output experiment directory
VAD_DIR=$4
config_path=$5 #config file directory
source ./$config_DIR

if [[ $INSTRUCTION = "prepare_train" ]]; then
	
fi

if [[ $INSTRUCTION = "train_ASR" ]]; then

fi

if [[ $INSTRUCTION = "decode_ASR" ]]; then
	
fi

if [[ $INSTRUCTION = "binarizer" ]]; then
	echo "ASR VAD"
	
	scores_path=$VAD_DIR/scores/chuck4min_logits_probs.npy
	vad_result=$VAD_DIR/result
	
	if [ ! -d $vad_result ];then
		mkdir -p $vad_result
	fi
	
	cat $VAD_DIR/rttm/* > $vad_result/vad.rttm
	score_vad.sh 
	
fi