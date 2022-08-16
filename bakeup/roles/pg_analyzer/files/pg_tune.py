#!/usr/bin/python3
# -*- coding: utf-8 -*-

import math


def analyze_shared_buffer(total):
    suggest_min = math.floor(total / 4)
    suggest_max = math.floor(total / 4 * 3)
    return suggest_min, suggest_max

