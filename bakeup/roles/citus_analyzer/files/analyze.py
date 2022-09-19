#!/usr/bin/python3
# -*- coding: utf-8 -*-

from concurrent.futures.thread import _worker
import os
import argparse
import logging
import yaml
import pg_tune

def publisher(parameter,str,flag):
    f = open('/root/tmp/result','a')
    if flag == 1:
        str = '###########################################################'
        +('parameter:['+parameter+'] is set properly') 
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

    # shards count
    shards_count = config['shards_count']
    workernum = config['worker_num']
    cpucores = config['cpu_cores']
    suggest_shards_count = pg_tune.analyze_shards_count(workernum, cpucores)
    if shards_count < suggest_shards_count[0]:
        str = '[shards count] is ' + shards_count 
        + ' \nThe suggest value is larger than'
        + suggest_shards_count[0]
        publisher('shards_count', str, 0)

    else:
        str = '[shards count] is ' + shards_count
        publisher('shards', str, 1)  
    
if __name__ == '__main__':
    main()
