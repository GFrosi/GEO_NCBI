def read_table(file_name):

    ctl = dict()
    treat = dict()


    with open(file_name, 'r') as file:

        for line in file:
            line = line.strip()
            gsm, srx, srr, category = line.split('|')

            srr_list = srr.split(',')

            if category == 'Control':  
                ctl[gsm] = srr_list

            else:
                treat[gsm] = srr_list

    return ctl, treat

def read_sample(file_name):

    sample = {}

    with open(file_name, 'r') as file:
        for line in file:
            line = line.strip()
            gsm, seq = line.split(',')

            sample[gsm] = seq

    return sample

                 

