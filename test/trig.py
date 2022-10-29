"""
Calculates the sine or cosine of the provided number.
The value is in radians scaled by 1e18, e.g. use a value of 1e18 for 1 radian.

usage: python trig.py <sin|cos|arcsin> <value>
"""

import subprocess, sys
from decimal import Decimal
from math import sin, cos, asin

# Parse arguments
if len(sys.argv) != 3:
    raise Exception("Must pass a method name and value")

method = sys.argv[1]
if method not in ["sin", "cos", "arcsin"]:
    raise Exception("Method must be sin, cos, or arcsin")

raw_input = Decimal(sys.argv[2])

if method in ["sin", "cos"]:
    raw_angle = raw_input
    if raw_angle < 0:
        raise Exception("Angle must be positive")

    angle = raw_angle / (10 ** 18)
    x = sin(angle) if method == "sin" else cos(angle)
else:
    arg = raw_input / (10 ** 18)
    x = asin(arg)

# Convert back to an integer scaled by 1e18, then ABI encode the result
y = int(x * 10 ** 18)
subprocess.run(["cast", "abi-encode", "f(int256)", str(y)])
