#!/usr/bin/env python
import sys

from scipy.misc import imread
from numpy import int16

Idiff =  imread(sys.argv[1]).astype(int16) - imread(sys.argv[2]).astype(int16)

sys.exit(int(Idiff.any()))
