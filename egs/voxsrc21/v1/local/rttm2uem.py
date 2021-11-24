import argparse
from pyannote.database.util import load_rttm

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="According to reference rttm file, create uem file")
    parser.add_argument('--lst_outpath', type=str, required=False, help="path of audio list file")
    parser.add_argument("ref_rttm_path", type=str, help="reference rttm file")
    parser.add_argument("uem_path", type=str, help="output uem file")
    args = parser.parse_args()

    groundtruth = load_rttm(args.ref_rttm_path)

    uem_lines = []
    for utt, timeline in groundtruth.items():
        max_endT = timeline.for_json()['content'][-1]['segment']['end']
        uem_line = "{} 1 0.000 {}\n".format(utt, max_endT)
        uem_lines.append(uem_line)
    with open(args.uem_path, "w") as uem_file:
        uem_file.writelines(uem_lines)

    if args.lst_outpath:
        with open(args.lst_outpath, "w") as lst_file:
            lst_file.writelines([line+'\n' for line in groundtruth.keys()])

    pass