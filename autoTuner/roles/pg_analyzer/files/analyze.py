#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import argparse
import logging
import yaml
import pg_tune

def publisher(parameter,str,flag):
    f = open('/root/tmp/result','a')
    if flag == 1:
        str = '###########################################################'
        + ('parameter:['+parameter+'] is set properly') 
        + str
        + '###########################################################'
    else:
        str = ('parameter:['+parameter+'] is not set properly') + str
    f.write(str+ '\n')
    f.close()

def main():
    parser = argparse.ArgumentParser(description='Script to auto parse config')
    parser.add_argument('-c', '--config', default='statistic.yml')
    parser.add_argument('-d', '--debug', action='store_true', default=False)
    args = parser.parse_args()

    if args.debug:
        logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', level=logging.DEBUG)
    else:
        logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', level=logging.INFO)

    # read scanned result
    f = open(args.config,'r')
    contents = f.read()
    config = yaml.load(contents, Loader=yaml.FullLoader)

    # shared memory
    shared_memory = config['shared_memory']
    total_memory = config['total_memory']
    sugest_memory = pg_tune.analyze_shared_buffer(total_memory)
    if shared_memory >= sugest_memory[0] and shared_memory <= sugest_memory[1]:
        str = '[shared memory] is ' + shared_memory
        publisher('shared_memory', str, 1)
    else:
        str = '[shared memory] is ' + shared_memory 
        + ' \nThe suggest value is '
        + sugest_memory[0]
        +'~ '
        + sugest_memory[1]
        publisher('shared_memory', str, 0)
    
if __name__ == '__main__':
    main()
