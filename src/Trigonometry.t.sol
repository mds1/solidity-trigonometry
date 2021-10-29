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
  TestTrigonometry internal trig;

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
    assertEq(trig.sin(0),      0);     // 0
    assertEq(trig.sin(4096),   32767); // pi/2
    assertEq(trig.sin(8192),   0);     // pi
    assertEq(trig.sin(12288), -32767); // 3pi/2
    assertEq(trig.sin(16384),  0);     // 2pi
    
    // Angles outside that range that must be wrapped
    assertEq(trig.sin(1e18 + 0),      0);     // 0
    assertEq(trig.sin(1e18 + 4096),   32767); // pi/2
    assertEq(trig.sin(1e18 + 8192),   0);     // pi
    assertEq(trig.sin(1e18 + 12288), -32767); // 3pi/2
    assertEq(trig.sin(1e18 + 16384),  0);     // 2pi
  }

  function testCos() public {
    // Angles within 0 <= x <= 2pi = 16384
    assertEq(trig.cos(0),      32767);  // 0
    assertEq(trig.cos(4096),   0);      // pi/2
    assertEq(trig.cos(8192),  -32767);  // pi
    assertEq(trig.cos(12288),  0);      // 3pi/2
    assertEq(trig.cos(16384),  32767);  // 2pi
    
    // Angles outside that range that must be wrapped
    assertEq(trig.cos(1e18 + 0),      32767);  // 0
    assertEq(trig.cos(1e18 + 4096),   0);      // pi/2
    assertEq(trig.cos(1e18 + 8192),  -32767);  // pi
    assertEq(trig.cos(1e18 + 12288),  0);      // 3pi/2
    assertEq(trig.cos(1e18 + 16384),  32767);  // 2pi
  }
}
