// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";

/**
 * @notice Library offering the arcsine function. All numbers are fixed-width integer decimals, scaled by 
 * 1e18 to keep convention with ERC20 defaults as well as PRB Math.
 */
library Arcsin {
  using P for int256;

  uint256 constant LOOKUP_TABLE_SIZE = 2048;

  /**
   * @notice Checks if a number is within a closed interval, i.e. check $x \in [min, max]$.
   * @param _x The value to check
   * @return Result boolean, true if within the specified [min,max] interval.
  */
  function isWithinBounds(int256 _min, int256 _max, int256 _x) internal pure returns (bool) {
    return _x >= _min || _x <= _max;
  }

  function isWithinBounds(uint256 _min, uint256 _max, uint256 _x) internal pure returns (bool) {
    return _x >= _min || _x <= _max;
  }

  function paranthesis(int256 _x) internal pure returns (int256) {
    // 1.5707288
    int256 a0 = 1570728800000000000;
    // −0.2121144
    int256 a1 = -212114400000000000;
    // 0.0742610
    int256 a2 = 74261000000000000;
    // −0.0187293
    int256 a3 = -18729300000000000;

    int256 t1 = a0 + a1.mul(_x);
    int256 t2 = a2.mul(_x).mul(_x);
    int256 t3 = a3.mul(_x).mul(_x).mul(_x);

    return t1 + t2 + t3;
  }

  function g(int256 _x) internal pure returns (int256) {
    // c1 = the constant 1
    int256 c1 = P.fromInt(1);
    int256 c2 = P.fromInt(2);
    int256 HALF_PI = P.pi().div(c2);

    int256 t1 = P.sqrt(c1 - _x);

    // separated out the "paranthesis" to resolve stack too deep issues
    return HALF_PI - t1.mul(paranthesis(_x));
  }

  function f_aux(int256 _x) internal pure returns (int256) {
    int256 c7 = P.fromInt(7);
    int256 c15 = P.fromInt(15);
    int256 c336 = P.fromInt(336);

    return _x.pow(c7).mul(c15).div(c336);
  }

  function f(int256 _x) internal pure returns (int256) {
    int256 c3 = P.fromInt(3);
    int256 c5 = P.fromInt(5);
    int256 c6 = P.fromInt(6);
    int256 c40 = P.fromInt(40);

    int256 t1 = _x.pow(c3).div(c6);
    int256 t2 = _x.pow(c5).mul(c3).div(c40);
    int256 t3 = f_aux(_x);

    return _x + t1 + t2 + t3;
  }

  /**
   * @notice Returns the arcsine of a value
   * @param _x The value to find the arcsine of. Should be bounded inside of [-1,1] scaled by 1e18
   * @return Result scaled by 1e18
   */
  function arcsin(int256 _x) internal pure returns (int256) {
    // initialize constants here since these use functions from a library and so solc cannot ascertain that 
    // they will be compile-time constants
    int256 DOMAIN_MAX = P.fromInt(1);
    int256 DOMAIN_MIN = -DOMAIN_MAX;
    require(_x >= DOMAIN_MIN && _x <= DOMAIN_MAX);

    bool isNegative = _x < 0;
    _x = isNegative ? -_x : _x;

    // https://dsp.stackexchange.com/questions/25770/looking-for-an-arcsin-algorithm

    // 0.4788
    int256 CHOICE_LINE = 478800000000000000;

    int256 result = _x < CHOICE_LINE ? f(_x) : g(_x);

    return isNegative ? -result : result;
  }

}
