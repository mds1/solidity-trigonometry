// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "ds-test/test.sol";

import "./SolidityTrigonometry.sol";

contract SolidityTrigonometryTest is DSTest {
    SolidityTrigonometry trigonometry;

    function setUp() public {
        trigonometry = new SolidityTrigonometry();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
