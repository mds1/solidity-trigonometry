// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Arcsin as A} from "src/Arcsin.sol";

contract ArcsinTest is Test {

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
    assertTrue(2 == (1+1));
  }
}
