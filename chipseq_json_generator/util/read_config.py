def read_config(file_name):
    config = {}

    with open(file_name,'r') as file:
        for line in file:
            
            k,v = line.strip().split('=')
            config[k] = v
    
    return config
