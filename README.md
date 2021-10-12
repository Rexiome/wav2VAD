#intruction
wav2VAD consists of an ASR system and a binarizer. The ASR system includes wav2vec 2.0 block and a connectionist temporal classification (CTC) decoder. 
The ASR generated a posterior probabilities of letters which were sent to a binarizer. 
In the binarizer, the phoneme classes corresponding to blank were considered as non-speech for the purpose of VAD and the rest of the classes were considered as speech

#requirement

pyannote-metrics=3.1
pyannote-audio=1.1.2

