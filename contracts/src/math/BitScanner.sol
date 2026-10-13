// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title BitScanner
/// @notice Ultra-optimized bitwise scanning library utilizing inline Yul assembly
library BitScanner {
    /// @notice Find the lowest set bit index (Count Trailing Zeros - CTZ) in a 256-bit word
    /// @param v The 256-bit word to scan
    /// @return pos Index (0-255) of the first bit set to 1. Returns 256 if v == 0.
    function findFirstSetBit(uint256 v) internal pure returns (uint16 pos) {
        assembly {
            if iszero(v) { pos := 256 }
            if iszero(eq(v, 0)) {
                let count := 0
                if iszero(and(v, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)) {
                    count := add(count, 128)
                    v := shr(128, v)
                }
                if iszero(and(v, 0xFFFFFFFFFFFFFFFF)) {
                    count := add(count, 64)
                    v := shr(64, v)
                }
                if iszero(and(v, 0xFFFFFFFF)) {
                    count := add(count, 32)
                    v := shr(32, v)
                }
                if iszero(and(v, 0xFFFF)) {
                    count := add(count, 16)
                    v := shr(16, v)
                }
                if iszero(and(v, 0xFF)) {
                    count := add(count, 8)
                    v := shr(8, v)
                }
                if iszero(and(v, 0xF)) {
                    count := add(count, 4)
                    v := shr(4, v)
                }
                if iszero(and(v, 0x3)) {
                    count := add(count, 2)
                    v := shr(2, v)
                }
                if iszero(and(v, 0x1)) {
                    count := add(count, 1)
                }
                pos := count
            }
        }
    }

    /// @notice Find the highest set bit index (Most Significant Bit - MSB) in a 256-bit word
    /// @param v The 256-bit word to scan
    /// @return pos Index (0-255) of the highest bit set to 1. Returns 256 if v == 0.
    function findLastSetBit(uint256 v) internal pure returns (uint16 pos) {
        assembly {
            if iszero(v) { pos := 256 }
            if iszero(eq(v, 0)) {
                let count := 0
                if gt(v, 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF) {
                    count := add(count, 128)
                    v := shr(128, v)
                }
                if gt(v, 0xFFFFFFFFFFFFFFFF) {
                    count := add(count, 64)
                    v := shr(64, v)
                }
                if gt(v, 0xFFFFFFFF) {
                    count := add(count, 32)
                    v := shr(32, v)
                }
                if gt(v, 0xFFFF) {
                    count := add(count, 16)
                    v := shr(16, v)
                }
                if gt(v, 0xFF) {
                    count := add(count, 8)
                    v := shr(8, v)
                }
                if gt(v, 0xF) {
                    count := add(count, 4)
                    v := shr(4, v)
                }
                if gt(v, 0x3) {
                    count := add(count, 2)
                    v := shr(2, v)
                }
                if gt(v, 0x1) {
                    count := add(count, 1)
                }
                pos := count
            }
        }
    }

    /// @notice Scans a 1024-bit mask (array of 4 uint256 words) for the highest active bit
    /// @param masks Bitmasks representing populated price ticks
    /// @return tick Index (0-1023) of the highest active tick, or 65535 if empty
    function scanHighestActiveTick(uint256[4] memory masks) internal pure returns (uint16 tick) {
        unchecked {
            for (int8 i = 3; i >= 0; i--) {
                uint256 mask = masks[uint256(int256(i))];
                if (mask != 0) {
                    uint16 bitPos = findLastSetBit(mask);
                    return uint16(uint256(int256(i)) * 256 + bitPos);
                }
            }
        }
        return 65535;
    }

    /// @notice Scans a 1024-bit mask (array of 4 uint256 words) for the lowest active bit
    /// @param masks Bitmasks representing populated price ticks
    /// @return tick Index (0-1023) of the lowest active tick, or 65535 if empty
    function scanLowestActiveTick(uint256[4] memory masks) internal pure returns (uint16 tick) {
        unchecked {
            for (uint256 i = 0; i < 4; i++) {
                uint256 mask = masks[i];
                if (mask != 0) {
                    uint16 bitPos = findFirstSetBit(mask);
                    return uint16(i * 256 + bitPos);
                }
            }
        }
        return 65535;
    }
}