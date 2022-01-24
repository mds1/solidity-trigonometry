"""
Calculates the sine or cosine of the provided number.
The value is in radians scaled by 1e18, e.g. use a value of 1e18 for 1 radian.

usage: python trig.py <sin|cos> <value>
"""

import subprocess, sys
from decimal import Decimal
from math import sin, cos

# Parse arguments
if len(sys.argv) != 3:
    raise Exception("Must pass a method name and value")

method, raw_angle = sys.argv[1], Decimal(sys.argv[2])
if method not in ["sin", "cos"]:
    raise Exception("Method must be sin or cos")
if raw_angle < 0:
    raise Exception("Angle must be positive")

# Do the calculation
angle = raw_angle / (10 ** 18)
x = sin(angle) if method == "sin" else cos(angle)

# Convert back to an integer scaled by 1e18, then ABI encode the result
y = int(x * 10 ** 18)
subprocess.run(["cast", "abi-encode", "f(int256)", str(y)])
