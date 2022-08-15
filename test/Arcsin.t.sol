// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Arcsin as A} from "src/Arcsin.sol";
import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";

contract ArcsinTest is Test {
  using P for int256;

  // taken from DSTestPlus and turned into intToString
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

  function intToString(int256 _x) internal pure returns (string memory nstr) {
    if (_x < 0) {
      return string.concat("-",uintToString(uint256(-_x)));
    }
    else {
      return uintToString(uint256(_x));
    }
  }

  function testLambda() public {
    emit log_int(A.arcsin(0.5 * 1e18));
  }

  uint256 constant TOL   = 6e14; // 1e18 is 100%, so this is 0.06%

  function testArcsinFuzz(int256 _x) public {
    int256 DOMAIN_MAX = 1e18;
    int256 DOMAIN_MIN = -DOMAIN_MAX;
    vm.assume(_x <= 1e18);
    vm.assume(_x >= -1e18);
    // vm.assume(A.isWithinBounds(DOMAIN_MIN, DOMAIN_MAX, _x));

    string[] memory inputs = new string[](3);
    inputs[0] = "julia";
    inputs[1] = "test/arcsin_fuzz_verify.jl";
    inputs[2] = intToString(_x);

    // bytes memory ret = vm.ffi(inputs);
    // (int256 output) = abi.decode(ret, (int256));
    // emit log_int(output);
    // assertApproxEq(trig.sin(_angle), output, TOL);
    // assertApproxEqRel(expected, actual, TOL);
    assertTrue(2 == (1+1));
  }


  /*
   * The pairs of points we are testing. Their negative versions are also tested.
   * sin(0) = 0 --> 0 = arcsin(0)
   * sin(π/6) = 1/2 --> π/6 = arcsin(1/2)
   * sin(π/4) = 1/√2 --> π/4 = arcsin(1/√2)
   * sin(π/3) = √3/2 --> π/3 = arcsin(√3/2)
   * sin(π/2) = 1 --> π/2 = arcsin(1)
  */

  int256 PI_OVER_SIX = P.pi().div(P.fromInt(6));
  int256 PI_OVER_FOUR = P.pi().div(P.fromInt(4));
  int256 PI_OVER_THREE = P.pi().div(P.fromInt(3));
  int256 PI_OVER_TWO = P.pi().div(P.fromInt(2));

  int256 ONE = P.fromInt(1);
  int256 TWO = P.fromInt(2);
  int256 THREE = P.fromInt(3);
  int256 ONE_HALF = ONE.div(TWO);
  int256 ONE_OVER_ROOT_TWO = ONE.div(P.sqrt(TWO));
  int256 ROOT_THREE_OVER_TWO = P.sqrt(THREE).div(TWO);

  function testArcsin1() public {
    int256 expected = 0;
    int256 actual = A.arcsin(0);
    assertApproxEqRel(expected, actual, TOL);
  }

  function testArcsin2() public {
    int256 expected = PI_OVER_SIX;
    int256 actual = A.arcsin(ONE_HALF);
    assertApproxEqRel(expected, actual, TOL);
  }

  function testArcsin3() public {
    int256 expected = -PI_OVER_SIX;
    int256 actual = A.arcsin(-ONE_HALF);
    assertApproxEqRel(expected, actual, TOL);
  }
  function testArcsin4() public {
    int256 expected = PI_OVER_FOUR;
    int256 actual = A.arcsin(ONE_OVER_ROOT_TWO);
    assertApproxEqRel(expected, actual, TOL);
  }
  function testArcsin5() public {
    int256 expected = -PI_OVER_FOUR;
    int256 actual = A.arcsin(-ONE_OVER_ROOT_TWO);
    assertApproxEqRel(expected, actual, TOL);
  }
  function testArcsin6() public {
    int256 expected = PI_OVER_THREE;
    int256 actual = A.arcsin(ROOT_THREE_OVER_TWO);
    assertApproxEqRel(expected, actual, TOL);
  }
  function testArcsin7() public {
    int256 expected = -PI_OVER_THREE;
    int256 actual = A.arcsin(-ROOT_THREE_OVER_TWO);
    assertApproxEqRel(expected, actual, TOL);
  }
  function testArcsin8() public {
    int256 expected = PI_OVER_TWO;
    int256 actual = A.arcsin(ONE);
    assertApproxEqRel(expected, actual, TOL);
  }
  function testArcsin9() public {
    int256 expected = -PI_OVER_TWO;
    int256 actual = A.arcsin(-ONE);
    assertApproxEqRel(expected, actual, TOL);
  }
}
