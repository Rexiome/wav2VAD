#!/bin/bash
#copyright wangjie xmuspeech 2021.10.11
#perform wav2VAD on voxSRC-21 set

. ./path.sh

SET=dev
exp_dir=exp
data_dir=data/voxsrc21
vad_dir=$exp_dir/model/wav2vec/fisher/dev
scores_path=$vad_dir/scores/fisher_chuck4min_logits_probs.npy
config_path=config/wav2vec_cfg.sh #including hyper-parameters
#prepare wav2vec train set 

#train wav2vec model

#decode to generate score file

#perform binarization
INSTRUCTION=binarizer
./instruction.sh $INSTRUCTION $SET $exp_dir $data_dir $vad_dir $scores_path $config_path

#perform score
INSTRUCTION=score
./instruction.sh $INSTRUCTION $SET $exp_dir $data_dir $vad_dir $scores_path $config_path

#grid search binarization
#result store in exp/model/wav2vec/fisher/dev/result/gridSearch_result.txt

#INSTRUCTION=binarizer_gridSearch
#./instruction.sh $INSTRUCTION $SET $exp_dir $data_dir $vad_dir $scores_path $config_path

#. ./path.sh
#
#SET=dev
#exp_dir=exp
#data_dir=data/voxsrc21
#vad_dir=$exp_dir/model/wav2vec/beam_search/dev
#config_path=config/wav2vec_cfg.sh
#scores_path=$vad_dir/scores/wemos_wav2bsvad.npy
#INSTRUCTION=score
#./instruction.sh $INSTRUCTION $SET $exp_dir $data_dir $vad_dir $scores_path $config_path
