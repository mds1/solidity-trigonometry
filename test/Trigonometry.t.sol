// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/Trigonometry.sol";

/**
 * @dev A note about precision and fuzz testing this library.
 *
 * These fuzz test bound the generated angle to avoid precision errors. Using floating point inputs
 * that are too large, whether with python's math.sin, numpy's sin, or mpmath's sin all result in
 * precision errors at large values. Entering the large decimal values into WolframAlpha gives
 * accurate results, but using their API would be very slow for fuzz testing.
 *
 * For example, let's take π/8, and add 1e18 * 2π. The sin of that value should match sin(π/8) = 0.3827.
 * As an integer for solidity, this gives us (π * 1e18) / 8 + 1e18 * (2π * 1e18) = 6283185307179586477317985848257729923
 * or 6283185307179586477.317985848257729923 as a decimal. First we check Wolfram Alpha, which
 * as expected returns 0.3827 from this query: https://www.wolframalpha.com/input?i=sin%286283185307179586477.317985848257729923%29
 *
 * This solidity implementation returns the same value as verified in `testSin12()` If we try to
 * replicate this in python, we get the wrong reult:
 *
 *   >>> import math
 *   >>> import numpy as np
 *   >>> from mpmath import mp
 *   >>> math.sin(6283185307179586477.317985848257729923)
 *     0.9842895889634229
 *   >>> np.sin(6283185307179586477.317985848257729923)
 *     0.9842895889634229
 *   >>> mp.sin(6283185307179586477.317985848257729923)
 *     mpf('0.98428958896342289')
 *
 * You can take the input modulo 2π first to reduce error, but that still results in output values
 * of about 0.9576, instead of the expected 0.3827.
 *
 * Similarly, for values too small, solidity's integer division can results in errors. As a result,
 * we simply bound the input to a minimum of 2πe18 with a reasonably large maximum, to ensure the
 * tests do not fail due to precision errors.
 *
 * Consequently, when using this library, you should also bound your inputs to a reasonable range.
 */

contract TestTrigonometry {
  function sin(uint256 _angle) public pure returns (int256) {
    return Trigonometry.sin(_angle);
  }

  function cos(uint256 _angle) public pure returns (int256) {
    return Trigonometry.cos(_angle);
  }
}

contract TrigonometryTest is Test {
  TestTrigonometry trig;
  uint256 constant SCALE = 1e18 * 2 * PI; // scale to add to trig inputs so same output is expected
  uint256 constant PI    = 3141592653589793238; // π as an 18 decimal value (wad), must match the value in Trigonometry.sol
  uint256 constant TOL   = 1.5e14; // relative tolerance, as a wad where 1e18 = 100%, so 1e14 = 0.015%

  function setUp() public {
    trig = new TestTrigonometry();
  }
}

contract Sine is TrigonometryTest {
  // --- Fuzz ---
  function testNoReverts(uint256 _angle) public view {
    trig.sin(_angle);
  }

  function testSinFuzz(uint256 _angle) public {
    _angle = bound(_angle, PI, 2000 * PI);

    string[] memory inputs = new string[](4);
    inputs[0] = "python3";
    inputs[1] = "test/trig.py";
    inputs[2] = "sin";
    inputs[3] = vm.toString(_angle);

    bytes memory ret = vm.ffi(inputs);
    (int256 output) = abi.decode(ret, (int256));
    assertApproxEqRel(trig.sin(_angle), output, TOL);
  }

  // --- Angles between 0 <= x <= 2π ---
  function testSin1() public {
    assertApproxEqRel(trig.sin(0), 0, TOL);
  }
  function testSin2() public {
    assertApproxEqRel(trig.sin(PI / 8), 382683432365089800, TOL);
  }
  function testSin3() public {
    assertApproxEqRel(trig.sin(PI / 4), 707106781186547500, TOL);
  }
  function testSin4() public {
    assertApproxEqRel(trig.sin(PI / 2), 1e18, TOL);
  }
  function testSin5() public {
    assertApproxEqRel(trig.sin(PI * 3 / 4), 707106781186547600, TOL);
  }
  function testSin6() public {
    assertApproxEqRel(trig.sin(PI), 0, TOL);
  }
  function testSin7() public {
    assertApproxEqRel(trig.sin(PI * 5 / 4), -707106781186547600, TOL);
  }
  function testSin8() public {
    assertApproxEqRel(trig.sin(PI * 3 / 2), -1e18, TOL);
  }
  function testSin9() public {
    assertApproxEqRel(trig.sin(PI * 7 / 4), -707106781186547600, TOL);
  }
  function testSin10() public {
    assertApproxEqRel(trig.sin(PI * 2), 0, TOL);
  }

  // --- Angles above 2π that must be wrapped ---
  function testSin11() public {
    assertApproxEqRel(trig.sin(SCALE + 0), 0, TOL);
  }
  function testSin12() public {
    assertApproxEqRel(trig.sin(SCALE + PI / 8), 382683432365089800, TOL);
  }
  function testSin13() public {
    assertApproxEqRel(trig.sin(SCALE + PI / 4), 707106781186547500, TOL);
  }
  function testSin14() public {
    assertApproxEqRel(trig.sin(SCALE + PI / 2), 1e18, TOL);
  }
  function testSin15() public {
    assertApproxEqRel(trig.sin(SCALE + PI * 3 / 4), 707106781186547600, TOL);
  }
  function testSin16() public {
    assertApproxEqRel(trig.sin(SCALE + PI), 0, TOL);
  }
  function testSin17() public {
    assertApproxEqRel(trig.sin(SCALE + PI * 5 / 4), -707106781186547600, TOL);
  }
  function testSin18() public {
    assertApproxEqRel(trig.sin(SCALE + PI * 3 / 2), -1e18, TOL);
  }
  function testSin19() public {
    assertApproxEqRel(trig.sin(SCALE + PI * 7 / 4), -707106781186547600, TOL);
  }
  function testSin20() public {
    assertApproxEqRel(trig.sin(SCALE + PI * 2), 0, TOL);
  }
}

contract Cosine is TrigonometryTest {
  // --- Fuzz ---
  function testNoReverts(uint256 _angle) public view {
    trig.cos(_angle);
  }

  function testCosFuzz(uint256 _angle) public {
    _angle = bound(_angle, PI, 2000 * PI);

    string[] memory inputs = new string[](4);
    inputs[0] = "python3";
    inputs[1] = "test/trig.py";
    inputs[2] = "cos";
    inputs[3] = vm.toString(_angle);

    bytes memory ret = vm.ffi(inputs);
    (int256 output) = abi.decode(ret, (int256));
    assertApproxEqRel(trig.cos(_angle), output, TOL);
  }

  // --- Angles between 0 <= x <= 2π ---
  function testCos1() public {
    assertApproxEqRel(trig.cos(0), 1e18, TOL);
  }
  function testCos2() public {
    assertApproxEqRel(trig.cos(PI / 8), 923879532511286756, TOL);
  }
  function testCos3() public {
    assertApproxEqRel(trig.cos(PI / 4), 707106781186547600, TOL);
  }
  function testCos4() public {
    assertApproxEqRel(trig.cos(PI / 2), 0, TOL);
  }
  function testCos5() public {
    assertApproxEqRel(trig.cos(PI * 3 / 4), -707106781186547600, TOL);
  }
  function testCos6() public {
    assertApproxEqRel(trig.cos(PI), -1e18, TOL);
  }
  function testCos7() public {
    assertApproxEqRel(trig.cos(PI * 5 / 4), -707106781186547600, TOL);
  }
  function testCos8() public {
    assertApproxEqRel(trig.cos(PI * 3 / 2), 0, TOL);
  }
  function testCos9() public {
    assertApproxEqRel(trig.cos(PI * 7 / 4), 707106781186547600, TOL);
  }
  function testCos10() public {
    assertApproxEqRel(trig.cos(PI * 2), 1e18, TOL);
  }

  // --- Angles above 2π that must be wrapped ---
  function testCos11() public {
    assertApproxEqRel(trig.cos(SCALE + 0), 1e18, TOL);
  }
  function testCos12() public {
    assertApproxEqRel(trig.cos(SCALE + PI / 8), 923879532511286756, TOL);
  }
  function testCos13() public {
    assertApproxEqRel(trig.cos(SCALE + PI / 4), 707106781186547600, TOL);
  }
  function testCos14() public {
    assertApproxEqRel(trig.cos(SCALE + PI / 2), 0, TOL);
  }
  function testCos15() public {
    assertApproxEqRel(trig.cos(SCALE + PI * 3 / 4), -707106781186547600, TOL);
  }
  function testCos16() public {
    assertApproxEqRel(trig.cos(SCALE + PI), -1e18, TOL);
  }
  function testCos17() public {
    assertApproxEqRel(trig.cos(SCALE + PI * 5 / 4), -707106781186547600, TOL);
  }
  function testCos18() public {
    assertApproxEqRel(trig.cos(SCALE + PI * 3 / 2), 0, TOL);
  }
  function testCos19() public {
    assertApproxEqRel(trig.cos(SCALE + PI * 7 / 4), 707106781186547600, TOL);
  }
  function testCos20() public {
    assertApproxEqRel(trig.cos(SCALE + PI * 2), 1e18, TOL);
  }
}
