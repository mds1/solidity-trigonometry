// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";

/**
 * @title Arcsine calculator.
 * @author Md Abid Sikder
 *
 * @notice Calculates arcsine. Fuzz testing shows that relative error is always
 * smaller than 0.01%. Uses the polynomial approximation functions found in
 * https://dsp.stackexchange.com/a/25771, but chooses between them at x=0.4788
 * due to differences in the relative errors as can be seen here
 * https://www.desmos.com/calculator/wrfwjhythe
 *
 * @dev See the desmos link for what functions f and g in the code refer to.
 */
library InverseTrigonometry {
  using P for int256;

  function g(int256 _x) internal pure returns (int256) {
    int256 ONE = 1000000000000000000;
    int256 TWO = 2000000000000000000;
    // 1.5707288
    int256 a0 = 1570728800000000000;
    // −0.2121144
    int256 a1 = -212114400000000000;
    // 0.0742610
    int256 a2 = 74261000000000000;
    // −0.0187293
    int256 a3 = -18729300000000000;

    int256 HALF_PI = P.pi().div(TWO);

    int256 root = P.sqrt(ONE - _x);

    return HALF_PI - root.mul(a0 + _x.mul(a1 + _x.mul(a2 + _x.mul(a3))));
  }

  function f(int256 _x) internal pure returns (int256) {
    int256 ONE = 1000000000000000000;
    int256 xSq = _x.mul(_x);

    // 1/6
    // https://www.wolframalpha.com/input?i=1%2F6
    // 0.1666666666666666666666666
    int256 frac1Div6 = 166666666666666666;

    // 3/40
    // https://www.wolframalpha.com/input?i=3%2F40
    // 0.075
    int256 frac3Div40 = 75000000000000000;

    // 15/336
    // https://www.wolframalpha.com/input?i=15%2F336
    // 0.044642857142857142857142857142
    int256 frac15Div336= 44642857142857142;

    return _x.mul(ONE + xSq.mul(frac1Div6 + xSq.mul(frac3Div40 + xSq.mul(frac15Div336))));
  }

  /**
     * @notice Arcsine function
     *
     * @param _x A integer with 18 fixed decimal points, where the whole part is bounded inside of [-1,1]
     *
     * @return The arcsine, with 18 fixed decimal points
     */
  function arcsin(int256 _x) internal pure returns (int256) {
    int256 DOMAIN_MAX = 1000000000000000000;
    int256 DOMAIN_MIN = -DOMAIN_MAX;
    require(_x >= DOMAIN_MIN && _x <= DOMAIN_MAX);

    // arcsin is an odd function, so arcsin(-x) = -arcsin(x), so we can remove
    // the negative here for easier math
    bool isNegative = _x < 0;
    _x = isNegative ? -_x : _x;

    // 0.4788
    int256 CHOICE_LINE = 478800000000000000;

    int256 result = _x < CHOICE_LINE ? f(_x) : g(_x);

    return isNegative ? -result : result;
  }
}
