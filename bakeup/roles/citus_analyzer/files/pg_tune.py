#!/usr/bin/python3
# -*- coding: utf-8 -*-

import math


def analyze_shards_count(workernum, cpucores):
    suggest_1 = workernum
    suggest_2 = workernum * cpucores * 1/4
    return suggest_1, suggest_2

