#!/usr/bin/env python

# Copyright xmuspeech
# @author wangjie 2021.8.20

import os
import argparse
import numpy as np
from tqdm.contrib import tqdm
from pyannote.database import get_protocol
from pyannote.database import FileFinder
from pyannote.audio.utils.signal import Binarize
from pyannote.core.feature import SlidingWindowFeature
from pyannote.core.segment import SlidingWindow


def write_vad_lab(vadTimeline, labFile):
    for seg in vadTimeline.for_json()["content"]:
        vadLine = "{:.3f} {:.3f} speech\n".format(seg['start'], seg['end'])
        labFile.write(vadLine)

def ASR_scoreLoad(score_path):
    scores = np.load(score_path, allow_pickle=True).item()
    return scores

def ASR_score2rttm(scores, out_dir, onset, offset, min_duration_on, min_duration_off, integral_frames):
    rttm_dir = os.path.join(out_dir, "rttm")
    lab_dir = os.path.join(out_dir, "lab")
    if not os.path.exists(rttm_dir):
        os.makedirs(rttm_dir)
    if not os.path.exists(lab_dir):
        os.makedirs(lab_dir)
    # create binarize model
    binarize = Binarize(offset=offset, onset=onset, log_scale=False,
                        min_duration_off=min_duration_off, min_duration_on=min_duration_on)

    for uri_id in tqdm(scores.keys()):
        # windows duraton is 0.025s, and windows shift is 0.02
        sad_slidingWin = SlidingWindow(duration=0.025, step=0.020)

        score = scores[uri_id][1]
        score = score.T

        sad_score = SlidingWindowFeature(score, sad_slidingWin)
        # scale score
        # sad_score.data = 1 -
        sad_score.data = 1 - sad_score.data
        kernel = np.array([0.4, 0.6])
        sad_score.data = np.convolve(sad_score.data[:, 0], kernel, 'same')[:, np.newaxis]
        # sad_score.data = score_filter(sad_score.data, integral_frames)
        # sad_score.data = (sad_score.data - min(sad_score.data)) / (max(sad_score.data) - min(sad_score.data))
        sys_timeline = binarize.apply(sad_score)

        with open(os.path.join(rttm_dir, uri_id + ".rttm"), "w") as rttmFile:
            sys_timeline.uri = uri_id
            sys_timeline.to_annotation().write_rttm(rttmFile)
        # generate lab files for segmentation
        with open(os.path.join(lab_dir, uri_id + ".lab"), "w") as labFile:
            write_vad_lab(sys_timeline, labFile)
    pass


# @output:exp/corpus/vod/**.rttm
#       such as:SPEAKER DH_EVAL_0001 1 155.117 0.395 <NA> <NA> A <NA> <NA>
#               SPEAKER DH_EVAL_0001 1 155.616 0.567 <NA> <NA> B <NA> <NA>
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="get vad rttm files of wav")
    parser.add_argument('--offset', type=float, required=False, help="Relative offset threshold of binarize")
    parser.add_argument('--onset', type=float, required=False, help="Relative onset threshold of binarize")
    parser.add_argument('--min_duration_off', required=False, type=float, help="Minimum duration of 0 label")
    parser.add_argument('--min_duration_on', required=False, type=float, help="Minimum duration of 1 label")
    parser.add_argument('--integral_frames', default=2, type=int,
                        help="time of frame * integral_frames = windows length of integral")
    parser.add_argument('score_path', type=str, help="ASR out put score file,such as ...")
    parser.add_argument('out_dir', type=str, help="mask rttm files and lab files output directory")

    args = parser.parse_args()

    # save_vad_rttm(protocol.test(), rttm_dir)
    print("hyperparameter onset:{} offset:{} min_duration_on:{} min_duration_off:{}".format(
        args.onset, args.offset, args.min_duration_on, args.min_duration_off))

    scores = ASR_scoreLoad(args.score_path)
    ASR_score2rttm(scores, args.out_dir, onset=args.onset, offset=args.offset,
                   min_duration_on=args.min_duration_on, min_duration_off=args.min_duration_off,
                   integral_frames=args.integral_frames)
