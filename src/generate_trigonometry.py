#!/usr/bin/env python

"""
Originally written by Lefteris Karapetsas (https://twitter.com/LefterisJP), with the source here:
    https://github.com/Sikorkaio/sikorka/blob/e75c91925c914beaedf4841c0336a806f2b5f66d/scripts/generate_trigonometry.py

This version is nearly identical to the original, and is kept in the repo for posterity in case
the original version is ever removed. This script was run with `number_of_bits = 32` to
generate the values used in the library.

Note that the regexes used in this script are tailored to the original version of Trigonometry.sol
by Lefteris, and therefore this script will not succeed if ran against the version in this repo.
This is because the library was reformatted to reduce gas usage. If you need to regenerate the
values, either update the regexes or run this script against the original Trigonometry.sol contract:
    https://github.com/Sikorkaio/sikorka/blob/e75c91925c914beaedf4841c0336a806f2b5f66d/contracts/trigonometry.sol
"""

from __future__ import division
import os
import math
import re
import sys


def re_replace_constant(string, typename, varname, value):
    constant_re = re.compile(
        r"({} +constant +{} +=) +(.*);".format(typename, varname)
    )
    match = constant_re.search(string)
    if not match:
        print(
            "ERROR: Could not match RE for '{}' during template generation.".
            format(varname)
        )
        sys.exit(1)

    if match.groups()[1] == str(value):
        # The value already exists in the source
        return string

    new_string = constant_re.sub(r"\1 {};".format(str(value)), string)
    return new_string


def re_replace_constant_and_type(string, typename, varname, value):
    constant_re = re.compile(
        r"( *)(.*) +constant +({}) += +(.*);".format(varname)
    )
    match = constant_re.search(string)
    if not match:
        print(
            "ERROR: Could not match RE for '{}' during template generation.".
            format(varname)
        )
        sys.exit(1)

    if match.groups()[1] == typename and match.groups()[3] == str(value):
        # The variable already exists in the source as we want it
        return string

    new_string = constant_re.sub(
        r"\1{} constant \3 = {};".format(typename, str(value)),
        string
    )
    return new_string


def re_replace_vardecl(string, typename, varname):
    var_re = re.compile(
        r"( *)(uint.*) +({});".format(varname)
    )
    match = var_re.search(string)
    if not match:
        print(
            "ERROR: Could not match RE for '{}' during template generation.".
            format(varname)
        )
        sys.exit(1)

    if match.groups()[1] == typename:
        # The variable already exists in the source as we want it
        return string

    new_string = var_re.sub(
        r"\1{} {};".format(typename, varname),
        string
    )
    return new_string


def re_replace_function_params(string, func_name, param_type):
    func_re = re.compile(
        r"( *)function {}\((.*?) *_angle\)".format(func_name)
    )
    match = func_re.search(string)
    if not match:
        print(
            "ERROR: Could not match function '{}' during template generation.".
            format(func_name)
        )
        sys.exit(1)

    if match.groups()[1] == param_type:
        # The type already exists in the source as we want it
        return string

    new_string = func_re.sub(
        r"\1function {}({} _angle)".format(func_name, param_type),
        string
    )
    return new_string


def re_replace_function_return(string, func_name, param_type):
    func_re = re.compile(
        r"( *)function {}\((.*)\)(.*)returns *\((.*?)\)".format(func_name)
    )
    match = func_re.search(string)
    if not match:
        print(
            "ERROR: Could not match function '{}' during template generation.".
            format(func_name)
        )
        sys.exit(1)

    if match.groups()[3] == param_type:
        # The type already exists in the source as we want it
        return string

    new_string = func_re.sub(
        r"\1function {}(\2)\3returns ({})".format(func_name, param_type),
        string
    )
    return new_string


def re_replace_comments(string, number_of_bits):
    angles_in_circle = 1 << (number_of_bits - 2)
    amplitude = (1 << (number_of_bits - 1)) - 1
    comment_re = re.compile(
        r'( *)\* @param _angle A (\d+)-bit angle. This divides'
        ' the circle into (\d+)'
    )
    match = comment_re.search(string)
    if not match:
        print(
            "ERROR: Could not match angle comment during template generation."
        )
        sys.exit(1)
    if (
            int(match.groups()[1]) != number_of_bits - 2
            or int(match.groups()[2]) == angles_in_circle
    ):
        new_string = comment_re.sub(
            r'\1* @param _angle A {}-bit angle. This divides'
            'the circle into {}'.format(
                str(number_of_bits - 2),
                angles_in_circle
            ),
            string
        )

    string = new_string
    comment_re = re.compile(
        r'( *)\* @return The sine result as a number in the range '
        '-(\d+) to (\d+)'
    )
    if not match:
        print(
            "ERROR: Could not match return comment during template generation."
        )
        sys.exit(1)
    if (
            int(match.groups()[1]) == amplitude
            and int(match.groups()[2]) == amplitude
    ):
        # The comment already exists in the source as we want it
        return string

    new_string = comment_re.sub(
        r'\1* @return The sine result as a number '
        'in the range -{} to {}'.format(
            amplitude,
            amplitude,
        ),
        string
    )

    return new_string


def gen_sin_table(number_of_bits, table_size):
    table = '"'
    number_of_bytes = int(number_of_bits / 8)
    amplitude = (1 << (number_of_bits - 1)) - 1
    for i in range(0, table_size):
        radians = (i * (math.pi / 2)) / (table_size - 1)
        sin_value = amplitude * math.sin(radians)
        table_value = round(sin_value)
        hex_value = "{0:0{1}x}".format(int(table_value), 2 * number_of_bytes)
        table += '\\x' + '\\x'.join(
            hex_value[i: i + 2] for i in range(0, len(hex_value), 2)
        )
    return table + '"'


def generate_trigonometry(number_of_bits, for_tests):
    print("Generating the sin() lookup table ...")
    table_size = (2 ** int(number_of_bits / 4)) + 1
    if number_of_bits % 8 != 0:
        print("ERROR: Bits should be a multiple of 8")
        sys.exit(1)

    path = os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        'contracts',
        'trigonometry.sol'
    )
    with open(path) as f:
        lines = f.read()

    uint_type_name = 'uint' + str(number_of_bits)
    lines = re_replace_constant(
        lines,
        'uint8',
        'entry_bytes',
        int(number_of_bits / 8)
    )
    lines = re_replace_constant(
        lines,
        'uint',
        'INDEX_WIDTH',
        int(number_of_bits / 4)
    )
    lines = re_replace_constant(
        lines,
        'uint',
        'INTERP_WIDTH',
        int(number_of_bits / 2)
    )
    lines = re_replace_constant(
        lines,
        'uint',
        'INDEX_OFFSET',
        '{} - INDEX_WIDTH'.format(number_of_bits - 4)
    )
    lines = re_replace_vardecl(lines, uint_type_name, 'trigint_value')
    lines = re_replace_constant_and_type(
        lines,
        uint_type_name,
        'ANGLES_IN_CYCLE',
        1 << (number_of_bits - 2)
    )
    lines = re_replace_constant(
        lines,
        'uint',
        'SINE_TABLE_SIZE',
        table_size - 1
    )
    lines = re_replace_constant_and_type(
        lines,
        uint_type_name,
        'QUADRANT_HIGH_MASK',
        int(1 << (number_of_bits - 3))
    )
    lines = re_replace_constant_and_type(
        lines,
        uint_type_name,
        'QUADRANT_LOW_MASK',
        int(1 << (number_of_bits - 4))
    )
    lines = re_replace_constant(
        lines,
        'bytes',
        'sin_table',
        gen_sin_table(number_of_bits, table_size)
    )
    lines = re_replace_function_params(
        lines,
        'sin',
        uint_type_name
    )
    lines = re_replace_function_params(
        lines,
        'cos',
        uint_type_name
    )
    lines = re_replace_function_return(
        lines,
        'sin_table_lookup',
        uint_type_name
    )
    lines = re_replace_comments(lines, number_of_bits)

    if for_tests:
        path = os.path.join(
            os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
            'contracts',
            'trigonometry_generated.sol'
        )
        lines = lines.replace(
            'library Trigonometry',
            'library TrigonometryGenerated'
        )

    with open(path, 'w') as f:
        f.write(lines)


if __name__ == '__main__':
    number_of_bits = 32
    generate_trigonometry(number_of_bits, for_tests=False)