// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {InverseTrigonometry as A} from "src/InverseTrigonometry.sol";
import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";

contract ArcsinTest is Test {
  using P for int256;

  // 1e14 = 0.01% relative error tolerance
  uint256 constant TOL = 1e14;

  /*
   * The pairs of points we are testing. Their negative versions are also
   * tested.
   *
   * sin(0) = 0 --> 0 = arcsin(0)
   * sin(π/6) = 1/2 --> π/6 = arcsin(1/2)
   * sin(π/4) = 1/√2 --> π/4 = arcsin(1/√2)
   * sin(π/3) = √3/2 --> π/3 = arcsin(√3/2)
   * sin(π/2) = 1 --> π/2 = arcsin(1)
   */

  int256 PI_OVER_TWO = P.pi().div(P.fromInt(2));
  int256 PI_OVER_THREE = P.pi().div(P.fromInt(3));
  int256 PI_OVER_FOUR = P.pi().div(P.fromInt(4));
  int256 PI_OVER_SIX = P.pi().div(P.fromInt(6));

  int256 ONE = P.fromInt(1);
  int256 TWO = P.fromInt(2);
  int256 THREE = P.fromInt(3);
  int256 ONE_HALF = ONE.div(TWO);
  int256 ONE_OVER_ROOT_TWO = ONE.div(P.sqrt(TWO));
  int256 ROOT_THREE_OVER_TWO = P.sqrt(THREE).div(TWO);

  // copied from DSTestPlus.sol
  // Convert uint to string, from https://github.com/mzhu25/sol2string/blob/13f566f7dc61c820c24a673da72d0114183a17c8/contracts/LibUintToString.sol
  uint256 private constant MAX_UINT256_STRING_LENGTH = 78;
  uint8 private constant ASCII_DIGIT_OFFSET = 48;
  function uintToString(uint256 n) internal pure returns (string memory nstr) {
    if (n == 0) return "0";

    // Overallocate memory
    nstr = new string(MAX_UINT256_STRING_LENGTH);
    uint256 k = MAX_UINT256_STRING_LENGTH;
    // Populate string from right to left (lsb to msb).
    while (n != 0) {
      assembly {
        let char := add(ASCII_DIGIT_OFFSET, mod(n, 10))
        mstore(add(nstr, k), char)
        k := sub(k, 1)
        n := div(n, 10)
      }
    }
    assembly {
      nstr := add(nstr, k) // shift pointer over to actual start of string
      mstore(nstr, sub(MAX_UINT256_STRING_LENGTH, k)) // store actual string length
    }
    return nstr;
  }

  function testArcsinFuzz(uint256 _x) public {
    uint256 DOMAIN_MAX = 1000000000000000000;
    _x = bound(_x, 0, DOMAIN_MAX);

    string[] memory inputs = new string[](4);
    inputs[0] = "python3";
    inputs[1] = "test/trig.py";
    inputs[2] = "arcsin";
    inputs[3] = uintToString(_x);

    bytes memory ret = vm.ffi(inputs);
    (int256 output) = abi.decode(ret, (int256));
    assertApproxEqRel(A.arcsin(int256(_x)), output, TOL);
  }

  function testNoReverts(int256 _x) public {
    int256 DOMAIN_MAX = 1000000000000000000;
    int256 DOMAIN_MIN = -DOMAIN_MAX;
    vm.assume(_x >= DOMAIN_MIN && _x <= DOMAIN_MAX);

    A.arcsin(_x);
  }

  function testArcsin1() public {
    int256 actual = A.arcsin(0);
    int256 expected = 0;
    assertApproxEqRel(actual, expected, TOL);
  }

  function testArcsin2() public {
    int256 actual = A.arcsin(ONE_HALF);
    int256 expected = PI_OVER_SIX;
    assertApproxEqRel(actual, expected, TOL);
  }

  function testArcsin3() public {
    int256 actual = A.arcsin(-ONE_HALF);
    int256 expected = -PI_OVER_SIX;
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin4() public {
    int256 actual = A.arcsin(ONE_OVER_ROOT_TWO);
    int256 expected = PI_OVER_FOUR;
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin5() public {
    int256 actual = A.arcsin(-ONE_OVER_ROOT_TWO);
    int256 expected = -PI_OVER_FOUR;
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin6() public {
    int256 actual = A.arcsin(ROOT_THREE_OVER_TWO);
    int256 expected = PI_OVER_THREE;
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin7() public {
    int256 actual = A.arcsin(-ROOT_THREE_OVER_TWO);
    int256 expected = -PI_OVER_THREE;
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin8() public {
    int256 actual = A.arcsin(ONE);
    int256 expected = PI_OVER_TWO;
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin9() public {
    int256 actual = A.arcsin(-ONE);
    int256 expected = -PI_OVER_TWO;
    assertApproxEqRel(actual, expected, TOL);
  }
}
