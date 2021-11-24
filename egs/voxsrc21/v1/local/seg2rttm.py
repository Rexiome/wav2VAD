import argparse
from pyannote.database.util import load_rttm
import numpy as np
import tqdm

def segment_load(seg_path):
    segment = np.load(seg_path, allow_pickle=True).item()
    return segment

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="convert segment file to rttm file")
    parser.add_argument("seg_path", type=str, help="input segment file path")
    parser.add_argument("rttm_path", type=str, help="output rttm file path")
    args = parser.parse_args()

    segment = segment_load(args.seg_path)
    rttm_lines = []
    for uri_id in tqdm.tqdm(segment.keys()):
        for time in segment[uri_id]:
            start_time, duration = time
            rttm_line = "SPEAKER {} 1 {} {} <NA> <NA> A <NA> <NA>\n".format(uri_id, start_time, duration)
            rttm_lines.append(rttm_line)

    with open(args.rttm_path, "w") as rttm_file:
        rttm_file.writelines(rttm_lines)

    pass