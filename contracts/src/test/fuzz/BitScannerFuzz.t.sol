// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../../src/math/BitScanner.sol";

contract BitScannerFuzzTest is Test {
    using BitScanner for uint256;

    /// @dev Fuzz test: Verifies that CTZ correctly finds the lowest set bit
    function testFuzz_FindFirstSetBit(uint8 bitPos) public pure {
        vm.assume(bitPos < 256);
        uint256 word = 1 << bitPos;
        uint16 foundPos = BitScanner.findFirstSetBit(word);
        assertEq(foundPos, bitPos, "CTZ bit position mismatch");
    }

    /// @dev Fuzz test: Verifies that MSB correctly finds the highest set bit
    function testFuzz_FindLastSetBit(uint8 bitPos) public pure {
        vm.assume(bitPos < 256);
        uint256 word = 1 << bitPos;
        uint16 foundPos = BitScanner.findLastSetBit(word);
        assertEq(foundPos, bitPos, "MSB bit position mismatch");
    }

    /// @dev Invariant test: Word of zeros returns 256
    function test_ZeroWordScanner() public pure {
        assertEq(BitScanner.findFirstSetBit(0), 256);
        assertEq(BitScanner.findLastSetBit(0), 256);
    }
}