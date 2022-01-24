// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "ds-test/test.sol";

interface Vm {
  // Performs a foreign function call via terminal, (stringInputs) => (result)
  function ffi(string[] calldata) external returns (bytes memory);
}

contract DSTestPlus is DSTest {
  Vm vm = Vm(HEVM_ADDRESS);

  function abs(int256 a) internal pure returns (int256) {
    return a >= 0 ? a : -a;
  }

  function min(int256 a, int256 b) internal pure returns (int256) {
    return a < b ? a : b;
  }

  function assertApproxEq(int256 a, int256 b, uint256 tol) internal virtual {
    // tol is a wad where 1e18 = 100%, and represents the maximum acceptable percentage tolerance
    // https://www.mathworks.com/matlabcentral/answers/26743-absolute-and-relative-tolerance-definitions
    if (a == b) return;

    if ((a < 0 && b > 0) || (a > 0 && b < 0)) {
      emit log("Error: a ~= b not satisfied, sign mismatch [uint]");
        emit log_named_int("    Expected", a);
        emit log_named_int("      Actual", b);
        fail();
        return;
    }

    uint256 relativeErr = uint256(1e18 * abs(a-b) / min(abs(a), abs(b)));
    if (relativeErr > tol) {
        emit log("Error: a ~= b not satisfied [uint]");
        emit log_named_int("    Expected", a);
        emit log_named_int("      Actual", b);
        emit log_named_uint(" Max % Delta", tol);
        emit log_named_uint("     % Delta", relativeErr);
        fail();
    }
  }

  // Wrap x to be in between min and max, inclusive
  // source: https://github.com/Rari-Capital/solmate/blob/32edfe8cf8e163515a30b1214d0480029f6094cd/src/test/utils/DSTestPlus.sol#L114-L133
  function bound(uint256 x, uint256 min, uint256 max) internal pure returns (uint256 result) {
    require(max >= min, "MAX_LESS_THAN_MIN");

    uint256 size = max - min;
    if (max != type(uint256).max) size++; // Make the max inclusive.
    if (size == 0) return min; // Using max would be equivalent as well.
    // Ensure max is inclusive in cases where x != 0 and max is at uint max.
    if (max == type(uint256).max && x != 0) x--; // Accounted for later.

    if (x < min) x += size * (((min - x) / size) + 1);
    result = min + ((x - min) % size);

    // Account for decrementing x to make max inclusive.
    if (max == type(uint256).max && x != 0) result++;
  }

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
}