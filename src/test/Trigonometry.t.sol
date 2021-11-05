// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "ds-test/test.sol";
import "../Trigonometry.sol";

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

  uint256 constant SCALE = 1e18 * 2 * PI; // scale to add to trig inputs so same output is expected
  uint256 constant PI    = 3141592653589793238; // pi as an 18 decimal value (wad)

  // We test with an absolute tolerance check, by asserting that the difference between the truth value
  // and returned value is less than TOL. With the current 32 byte lookup table, we can set this tolerance
  // as low as 9e-8 for the y=sin(x) and y=cos(x) outputs. With a 16 byte lookup table, we had to set this
  // value to 0.00038 for tests to pass
  int256 constant TOL   = 90000000000; // was a wad, so 90000000000 = 90000000000/1e18 = 9e-8

  function abs(int256 a) internal pure returns (int256) {
    return a >= 0 ? a : -a;
  }

  function assertApproxEq(int256 a, int256 b) internal {
    if (abs(a - b) > TOL) {
      emit log("Error: a ~= b not satisfied [uint]");
      emit log_named_int("  Expected", b);
      emit log_named_int("    Actual", a);
      fail();
    }
  }

  function setUp() public {
    trig = new TestTrigonometry();
  }
}

contract Scribble is TrigonometryTest {
  // Trying to autogenerate some scribble properties from these tests

  function testNoReverts1(uint256 _angle) public view { 
    // Should not revert for any input
    trig.sin(_angle);
  }

  function testNoReverts2(uint256 _angle) public { 
    // Should not revert for any input, but including an assertion
    assertLt(-1.1e18, trig.sin(_angle));
  }

  function testSinOutputRange(uint256 _angle) public {
    // Verify outputs are between -1e18 and 1e18
    assertGe(1e18, trig.sin(_angle));
    assertLe(-1e18, trig.sin(_angle));
  }
}

contract Sine is TrigonometryTest {
  // --- Angles between 0 <= x <= 2pi ---
  function testSin1() public {
    assertApproxEq(trig.sin(0), 0);
  }
  function testSin2() public {
    assertApproxEq(trig.sin(PI / 8), 382683432365089800);
  }
  function testSin3() public {
    assertApproxEq(trig.sin(PI / 4), 707106781186547500);
  }
  function testSin4() public {
    assertApproxEq(trig.sin(PI / 2), 1e18);
  }
  function testSin5() public {
    assertApproxEq(trig.sin(PI * 3 / 4), 707106781186547600);
  }
  function testSin6() public {
    assertApproxEq(trig.sin(PI), 0);
  }
  function testSin7() public {
    assertApproxEq(trig.sin(PI * 5 / 4), -707106781186547600);
  }
  function testSin8() public {
    assertApproxEq(trig.sin(PI * 3 / 2), -1e18);
  }
  function testSin9() public {
    assertApproxEq(trig.sin(PI * 7 / 4), -707106781186547600);
  }
  function testSin10() public {
    assertApproxEq(trig.sin(PI * 2), 0);
  }

  // --- Angles above 2pi that must be wrapped ---
  function testSin11() public {
    assertApproxEq(trig.sin(SCALE + 0), 0);
  }
  function testSin12() public {
    assertApproxEq(trig.sin(SCALE + PI / 8), 382683432365089800);
  }
  function testSin13() public {
    assertApproxEq(trig.sin(SCALE + PI / 4), 707106781186547500);
  }
  function testSin14() public {
    assertApproxEq(trig.sin(SCALE + PI / 2), 1e18);
  }
  function testSin15() public {
    assertApproxEq(trig.sin(SCALE + PI * 3 / 4), 707106781186547600);
  }
  function testSin16() public {
    assertApproxEq(trig.sin(SCALE + PI), 0);
  }
  function testSin17() public {
    assertApproxEq(trig.sin(SCALE + PI * 5 / 4), -707106781186547600);
  }
  function testSin18() public {
    assertApproxEq(trig.sin(SCALE + PI * 3 / 2), -1e18);
  }
  function testSin19() public {
    assertApproxEq(trig.sin(SCALE + PI * 7 / 4), -707106781186547600);
  }
  function testSin20() public {
    assertApproxEq(trig.sin(SCALE + PI * 2), 0);
  }

  // --- Verify the method cannot revert for any input ---
  function testNoReverts(uint256 _angle) public view { 
    trig.sin(_angle);
  }
}

contract Cosine is TrigonometryTest {
  // --- Angles between 0 <= x <= 2pi ---
  function testCos1() public {
    assertApproxEq(trig.cos(0), 1e18);
  }
  function testCos2() public {
    assertApproxEq(trig.cos(PI / 8), 923879532511286756);
  }
  function testCos3() public {
    assertApproxEq(trig.cos(PI / 4), 707106781186547600);
  }
  function testCos4() public {
    assertApproxEq(trig.cos(PI / 2), 0);
  }
  function testCos5() public {
    assertApproxEq(trig.cos(PI * 3 / 4), -707106781186547600);
  }
  function testCos6() public {
    assertApproxEq(trig.cos(PI), -1e18);
  }
  function testCos7() public {
    assertApproxEq(trig.cos(PI * 5 / 4), -707106781186547600);
  }
  function testCos8() public {
    assertApproxEq(trig.cos(PI * 3 / 2), 0);
  }
  function testCos9() public {
    assertApproxEq(trig.cos(PI * 7 / 4), 707106781186547600);
  }
  function testCos10() public {
    assertApproxEq(trig.cos(PI * 2), 1e18);
  }

  // --- Angles above 2pi that must be wrapped ---
  function testCos11() public {
    assertApproxEq(trig.cos(SCALE + 0), 1e18);
  }
  function testCos12() public {
    assertApproxEq(trig.cos(SCALE + PI / 8), 923879532511286756);
  }
  function testCos13() public {
    assertApproxEq(trig.cos(SCALE + PI / 4), 707106781186547600);
  }
  function testCos14() public {
    assertApproxEq(trig.cos(SCALE + PI / 2), 0);
  }
  function testCos15() public {
    assertApproxEq(trig.cos(SCALE + PI * 3 / 4), -707106781186547600);
  }
  function testCos16() public {
    assertApproxEq(trig.cos(SCALE + PI), -1e18);
  }
  function testCos17() public {
    assertApproxEq(trig.cos(SCALE + PI * 5 / 4), -707106781186547600);
  }
  function testCos18() public {
    assertApproxEq(trig.cos(SCALE + PI * 3 / 2), 0);
  }
  function testCos19() public {
    assertApproxEq(trig.cos(SCALE + PI * 7 / 4), 707106781186547600);
  }
  function testCos20() public {
    assertApproxEq(trig.cos(SCALE + PI * 2), 1e18);
  }

  // --- Verify the method cannot revert for any input ---
  function testNoReverts(uint256 _angle) public view { 
    trig.cos(_angle);
  }
}