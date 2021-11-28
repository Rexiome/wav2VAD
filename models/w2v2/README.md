1、数据准备
如果是带segments的数据集，运行sh ./segments2dataset.sh --data_dir data_seg
如果是不带segments的数据集，运行sh ./wavscp2dataset.sh --data_dir data_noseg
注意：--data_dir是包含kaldi数据准备文件的目录(text wav.scp utt2dur等等)
###############################################################################
1.1、如果是带segments的数据集，还需要进行音频裁剪(根据utt_id)，便于训练，此步需要ffmpeg（git clone）
sh dataset2trim.sh --dataset_path data_seg/tmp/dataset --trim_audio_outputdir /data3/w2v2
构造data_seg/tmp/run_trim文件，里面每行都是ffmpeg指令，接着需要将文件拆成10份便于并行 > data_seg/tmp/run_trim[0-9]
--dataset_path是上一步输出的dataset文件
--trim_audio_outputdir是音频被裁剪后希望存储路径，尽量空间大点的
最后run.pl并行执行文件data_seg/tmp/run_trim[0-9]中的指令，将裁剪后的音频全部存入trim_audio_outputdir
time /tsdata/kaldi_utils/run.pl JOB=1:10 data_seg/tmp/log.JOB.txt sh run_trim_ffmpeg.sh --file_name data_seg/tmp/run_trim  --index JOB
###############################################################################
2、将dataset转为huggingface/datasets类
time python make_hfdatasets.py  \
--input_train_file=data_seg/tmp/dataset  \
--save_path=./hf_datasets \
--segments_mode \
--trim_audio_path=/data3/w2v2 \
--is_ch
或者sh run_make_hfdatasets.sh(自行更改脚本中参数)
--segments_mode下需要传入trim_audio_path，与上一步的trim_audio_outputdir保持一致，用于更改音频路径，使其指向裁剪后的音频路径
--is_ch表示处理中文数据集，默认在字间插入空格
还可以传入input_train_file、input_dev_file、input_test_file
3、微调w2v2模型
sh run_finetune_w2v2.sh(自行更改脚本中参数)