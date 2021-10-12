#!/bin/bash
#copyright wangjie xmuspeech 2021.10.9

ref=
sys=
uem=
collar=0
source parse_options.sh

set -e
if [ ! -d pyannoteConfig ]; then
	mkdir -p pyannoteConfig
fi
#prepare yml file for pyannote.metrics
echo "Protocols:
  corpus:
    SpeakerDiarization:
      corpus:
        development:
          annotated: ./corpus.development.uem
          annotation: ./corpus.development.rttm
          uri: ./corpus.development.lst
" > pyannoteConfig/database.yml

cp $ref pyannoteConfig/corpus.development.rttm

#prepare train uem file
if [ -n "$uem" ]; then
	if [ -f "$uem" ]; then
		cp $uem pyannoteConfig/corpus.development.uem
	else
		echo "not exit uem file"
	fi
else
	if [ -f "pyannoteConfig/corpus.development.uem" ]; then
		echo "pyannoteConfig/corpus.development.uem file already exits. use it" 
	else
		echo "uem file does not exits. create it"
		python local/rttm2uem.py --lst_outpath pyannoteConfig/corpus.development.lst $ref \
			pyannoteConfig/corpus.development.uem
	fi
	
fi

export PYANNOTE_DATABASE_CONFIG=pyannoteConfig/database.yml
pyannote-metrics detection --subset=development corpus.SpeakerDiarization.corpus $sys

