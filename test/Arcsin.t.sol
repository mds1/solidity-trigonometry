// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Arcsin as A} from "src/Arcsin.sol";
import {PRBMathSD59x18 as P} from "prb-math/PRBMathSD59x18.sol";

contract ArcsinTest is Test {
  using P for int256;

  /*
  The pairs of points we are testing. Their negative versions are also tested.
  sin(0) = 0 --> 0 = arcsin(0)
  sin(π/6) = 1/2 --> π/6 = arcsin(1/2)
  sin(π/4) = 1/√2 --> π/4 = arcsin(1/√2)
  sin(π/3) = √3/2 --> π/3 = arcsin(√3/2)
  sin(π/2) = 1 --> π/2 = arcsin(1)
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

  function testArcsinLambda() public {
    int256 expected = 978700963100;
    int256 actual = A.arcsin(978700963100);
    assertApproxEqRel(actual, expected, TOL);
  }

  function testArcsin1() public {
    int256 expected = 0;
    int256 actual = A.arcsin(0);
    assertApproxEqRel(actual, expected, TOL);
  }

  function testArcsin2() public {
    int256 expected = PI_OVER_SIX;
    int256 actual = A.arcsin(ONE_HALF);
    assertApproxEqRel(actual, expected, TOL);
  }

  function testArcsin3() public {
    int256 expected = -PI_OVER_SIX;
    int256 actual = A.arcsin(-ONE_HALF);
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin4() public {
    int256 expected = PI_OVER_FOUR;
    int256 actual = A.arcsin(ONE_OVER_ROOT_TWO);
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin5() public {
    int256 expected = -PI_OVER_FOUR;
    int256 actual = A.arcsin(-ONE_OVER_ROOT_TWO);
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin6() public {
    int256 expected = PI_OVER_THREE;
    int256 actual = A.arcsin(ROOT_THREE_OVER_TWO);
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin7() public {
    int256 expected = -PI_OVER_THREE;
    int256 actual = A.arcsin(-ROOT_THREE_OVER_TWO);
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin8() public {
    int256 expected = PI_OVER_TWO;
    int256 actual = A.arcsin(ONE);
    assertApproxEqRel(actual, expected, TOL);
  }
  function testArcsin9() public {
    int256 expected = -PI_OVER_TWO;
    int256 actual = A.arcsin(-ONE);
    assertApproxEqRel(actual, expected, TOL);
  }
}
