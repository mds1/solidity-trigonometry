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
  int256 constant TOL = 380000000000000; // equal to 0.00038 tolerance on y = sin(x) outputs

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

  function testSin() public {
    // Angles within 0 <= x <= 2pi
    assertApproxEq(trig.sin(0),            0,                  TOL);
    assertApproxEq(trig.sin(PI / 8),       382683432365089800, TOL);
    assertApproxEq(trig.sin(PI / 4),       707106781186547500, TOL);
    assertApproxEq(trig.sin(PI / 2),       1e18,               TOL);
    assertApproxEq(trig.sin(PI * 3 / 4),   707106781186547600, TOL);
    assertApproxEq(trig.sin(PI),           0,                  TOL);
    assertApproxEq(trig.sin(PI * 5 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.sin(PI * 3 / 2),  -1e18,               TOL);
    assertApproxEq(trig.sin(PI * 7 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.sin(PI * 2),       0,                  TOL);

    // Angles outside that range that must be wrapped
    uint256 scale = 1e18 * 2 * PI;
    assertApproxEq(trig.sin(scale + 0),            0,                  TOL);
    assertApproxEq(trig.sin(scale + PI / 8),       382683432365089800, TOL);
    assertApproxEq(trig.sin(scale + PI / 4),       707106781186547500, TOL);
    assertApproxEq(trig.sin(scale + PI / 2),       1e18,               TOL);
    assertApproxEq(trig.sin(scale + PI * 3 / 4),   707106781186547600, TOL);
    assertApproxEq(trig.sin(scale + PI),           0,                  TOL);
    assertApproxEq(trig.sin(scale + PI * 5 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.sin(scale + PI * 3 / 2),  -1e18,               TOL);
    assertApproxEq(trig.sin(scale + PI * 7 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.sin(scale + PI * 2),       0,                  TOL);
  }

  function testCos() public {
    // Angles within 0 <= x <= 2pi
    assertApproxEq(trig.cos(0),            1e18,               TOL);
    assertApproxEq(trig.cos(PI / 8),       923879532511286756, TOL);
    assertApproxEq(trig.cos(PI / 4),       707106781186547600, TOL);
    assertApproxEq(trig.cos(PI / 2),       0,                  TOL);
    assertApproxEq(trig.cos(PI * 3 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.cos(PI),          -1e18,               TOL);
    assertApproxEq(trig.cos(PI * 5 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.cos(PI * 3 / 2),   0,                  TOL);
    assertApproxEq(trig.cos(PI * 7 / 4),   707106781186547600, TOL);
    assertApproxEq(trig.cos(PI * 2),       1e18,               TOL);

    // Angles outside that range that must be wrapped
    uint256 scale = 1e18 * 2 * PI;
    assertApproxEq(trig.cos(scale + 0),            1e18,               TOL);
    assertApproxEq(trig.cos(scale + PI / 8),       923879532511286756, TOL);
    assertApproxEq(trig.cos(scale + PI / 4),       707106781186547600, TOL);
    assertApproxEq(trig.cos(scale + PI / 2),       0,                  TOL);
    assertApproxEq(trig.cos(scale + PI * 3 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.cos(scale + PI),          -1e18,               TOL);
    assertApproxEq(trig.cos(scale + PI * 5 / 4),  -707106781186547600, TOL);
    assertApproxEq(trig.cos(scale + PI * 3 / 2),   0,                  TOL);
    assertApproxEq(trig.cos(scale + PI * 7 / 4),   707106781186547600, TOL);
    assertApproxEq(trig.cos(scale + PI * 2),       1e18,               TOL);
  }
}
