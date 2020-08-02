import argparse
from util.read_cateory_table import read_table, read_sample
from util.read_config import read_config
import os 



def print_json(config, chip_ctl, chip_treat):
    print('{')
    print(chip_ctl)
    print()
    print(chip_treat)
    
    for k,v in config.items():
        print('"'+ k + '":' + v)
    
    print('}')




def prepare_sample_json(ctl, treat, sample, srr_path):
    chip_ctl = ''
    chip_treat = ''

    for gsm, seq_type in sample.items():
        if seq_type == 'single':
            if gsm in ctl.keys():
                for i,srr in enumerate(ctl[gsm]):
                    chip_ctl += '"chip.ctl_fastqs_rep'+ str(i+1) + '_R1" : ["' + os.path.join(srr_path,srr) + '_1.fastq.gz"],\n'
            
            if gsm in treat.keys():
                for i,srr in enumerate(treat[gsm]):
                    chip_treat += '"chip.fastqs_rep'+ str(i+1) + '_R1" : ["' + os.path.join(srr_path,srr) + '_1.fastq.gz"],\n'
    
        else:
            if gsm in ctl.keys():
                for i,srr in enumerate(ctl[gsm]):
                    chip_ctl += '"chip.ctl_fastqs_rep'+ str(i+1) + '_R1" : ["' + os.path.join(srr_path,srr) + '_1.fastq.gz"],\n"chip.ctl_fastqs_rep'+ str(i+1) + '_R2" : ["' + os.path.join(srr_path,srr) + '_2.fastq.gz"],\n' 
            
            if gsm in treat.keys():
                for i,srr in enumerate(treat[gsm]):
                    chip_treat += '"chip.fastqs_rep'+ str(i+1) + '_R1" : ["' + os.path.join(srr_path,srr) + '_1.fastq.gz"],\n"chip.fastqs_rep'+ str(i+1) + '_R2" : ["' + os.path.join(srr_path,srr) + '_2.fastq.gz"],\n'

    return chip_ctl, chip_treat



def main():
    ctl, treat = read_table(args.table)
    config = read_config(args.config)
    sample = read_sample(args.sample)
    chip_ctl, chip_treat = prepare_sample_json(ctl, treat, sample, args.path)
    print_json(config, chip_ctl, chip_treat)

if __name__ == "__main__":

    parser = argparse.ArgumentParser(
        description="A tool to create json input files for the IHEC pipeline")

    parser.add_argument('-t', '--table', action="store",
                        help='The Category table with GSM, SRX, SRR, Category columns',
                        required=True)

    parser.add_argument('-c', '--config', action='store',
                        help='The json config file',
                        required=True)

    parser.add_argument('-s', '--sample', action='store',
                        help='The samples (GSM) with single or pair end information after download SRR files',
                        required=True)

    parser.add_argument('-p', '--path', action='store',
                        help='The SRR path',
                        required=True)
    
    args = parser.parse_args()
    main()