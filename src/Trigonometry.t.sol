// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.7;
import "ds-test/test.sol";

import "./Trigonometry.sol";

contract TestTrigonometry {
  function sin(uint256 _angle) public pure returns (int256) {
    return Trigonometry.sin(_angle);
  }

  function cos(uint256 _angle) public pure returns (int256) {
    return Trigonometry.cos(_angle);
  }
}

contract TrigonometryTest is DSTest {
  TestTrigonometry trig;

  uint256 constant PI = 3141592653589793238; // pi as an 18 decimal value (wad)
  int256 constant TOL = 1; // values are denominated in 1e18, so this is the smallest nonzero tolerance

  function abs(int256 a) internal pure returns (int256) {
    return a >= 0 ? a : -a;
  }

  function assertApproxEq(int256 a, int256 b, int256 abstol) internal {
      if (abs(a - b) > abstol) {
          emit log("Error: a ~= b not satisfied [uint]");
          emit log_named_int("  Expected", b);
          emit log_named_int("    Actual", a);
          fail();
      }
    }

  function setUp() public {
    trig = new TestTrigonometry();
  }

  function testFailBasicSanity() public {
    assertTrue(false);
  }

  function testBasicSanity() public {
    assertTrue(true);
  }

  function testSin() public {
    // Angles within 0 <= x <= 2pi = 16384
    assertApproxEq(trig.sin(0),           0,    TOL); // 0
    assertApproxEq(trig.sin(PI/2),        1e18, TOL); // pi/2
    assertApproxEq(trig.sin(PI),          0,    TOL); // pi
    assertApproxEq(trig.sin(3 * PI / 2), -1e18, TOL); // 3pi/2
    assertApproxEq(trig.sin(2 * PI),      0,    TOL); // 2pi
    
    // Angles outside that range that must be wrapped
    assertApproxEq(trig.sin(1e18 * 2 * PI + 0),           0,    TOL); // 0
    assertApproxEq(trig.sin(1e18 * 2 * PI + PI/2),        1e18, TOL); // pi/2
    assertApproxEq(trig.sin(1e18 * 2 * PI + PI),          0,    TOL); // pi
    assertApproxEq(trig.sin(1e18 * 2 * PI + 3 * PI / 2), -1e18, TOL); // 3pi/2
    assertApproxEq(trig.sin(1e18 * 2 * PI + 2 * PI),      0,    TOL); // 2pi
  }

  function testCos() public {
    // Angles within 0 <= x <= 2pi = 2 * PI
    assertApproxEq(trig.cos(0),           1e18, TOL); // 0
    assertApproxEq(trig.cos(PI/2),        0,    TOL); // pi/2
    assertApproxEq(trig.cos(PI),         -1e18, TOL); // pi
    assertApproxEq(trig.cos(3 * PI / 2),  0,    TOL); // 3pi/2
    assertApproxEq(trig.cos(2 * PI),      1e18, TOL); // 2pi
    
    // Angles outside that range that must be wrapped
    assertApproxEq(trig.cos(1e18 * 2 * PI + 0),           1e18, TOL); // 0
    assertApproxEq(trig.cos(1e18 * 2 * PI + PI/2),        0,    TOL); // pi/2
    assertApproxEq(trig.cos(1e18 * 2 * PI + PI),         -1e18, TOL); // pi
    assertApproxEq(trig.cos(1e18 * 2 * PI + 3 * PI / 2),  0,    TOL); // 3pi/2
    assertApproxEq(trig.cos(1e18 * 2 * PI + 2 * PI),      1e18, TOL); // 2pi
  }
}
