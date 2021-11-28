#!/bin/bash
#time python make_hfdatasets.py  \
#--input_train_file=data_noseg/tmp/dataset  \
#--save_path=./hf_datasets \
#--is_ch
time python make_hfdatasets.py  \
--input_train_file=data_seg/tmp/dataset  \
--save_path=./hf_datasets \
--segments_mode \
--trim_audio_path=/data3/w2v2 \
--is_ch