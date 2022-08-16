#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import argparse
import logging
import yaml

def parse_config():
    parser = argparse.ArgumentParser(description='Script to auto parse config')
    parser.add_argument('-c', '--config', default='statistic.yml')
    parser.add_argument('-d', '--debug', action='store_true', default=False)
    args = parser.parse_args()

    if args.debug:
        logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', level=logging.DEBUG)
    else:
        logging.basicConfig(format='%(asctime)s %(levelname)s: %(message)s', level=logging.INFO)

    # read config file
    f = open(args.config,'r')
    contents = f.read()
    config = yaml.load(contents, Loader=yaml.FullLoader)