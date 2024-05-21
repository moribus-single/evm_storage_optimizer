// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {StorageOptimizer} from "../src/StorageOptimizer.sol";

/**
 * @title Tests for packing multiple values
 */
contract FuzzzingTestsMultipleValues is Test {
    /// @notice Bits that must be checked
    uint8[] public fixtureBits = [8, 16, 32, 64, 128];

    /**
     * Fuzzing test to check that packing some values with the same amount of bits
     * works properly.
     *
     * @param bits Bits value that is fuzzed
     */
    function testFuzz_PackWithSimilarBits(uint8 bits) public pure {
        vm.assume(bits > 7);

        // Amount of values for packing
        uint256 valuesLength = 256 / bits;

        // Initialize values and bits arrays with some values
        uint256[] memory values = new uint256[](valuesLength);
        uint8[] memory bitsPerValues = new uint8[](valuesLength);
        for (uint8 i; i < valuesLength; i++) {
            bitsPerValues[i] = bits;
            values[i] = 2 ** bits - 1 - i * 2;
        }

        // Pack the values and unpack back
        uint256 packedSlot = StorageOptimizer.packValues(values, bitsPerValues);
        uint256[] memory unpackedValues = StorageOptimizer.unpackValues(
            packedSlot,
            bitsPerValues
        );

        // Check data integrity
        assertEq(unpackedValues.length, valuesLength);
        for (uint i; i < valuesLength; i++) {
            assertEq(values[i], unpackedValues[i]);
        }
    }

    /**
     * Fuzzing test to check that packing some values with different amount of bits
     * works properly.
     *
     * @param bits Fuzzed array of bits for each value
     */
    /// forge-config: default.fuzz.runs = 1500
    function test_PackWithDifferentBits(uint8[] memory bits) public pure {
        vm.assume(_sum(bits) <= 256);

        // Amount of values for packing
        uint256 valuesLength = bits.length;

        // Initialize values and bits arrays with some values
        uint256[] memory values = new uint256[](valuesLength);
        for (uint8 i; i < valuesLength; i++) {
            if (bits[i] != 256) {
                values[i] = 2 ** bits[i] - 1;
            } else {
                values[i] = type(uint256).max;
            }
        }

        // Pack the values and unpack back
        uint256 packedSlot = StorageOptimizer.packValues(values, bits);
        uint256[] memory unpackedValues = StorageOptimizer.unpackValues(
            packedSlot,
            bits
        );

        // Check data integrity
        assertEq(unpackedValues.length, valuesLength);
        for (uint i; i < valuesLength; i++) {
            assertEq(values[i], unpackedValues[i]);
        }
    }

    function _sum(uint8[] memory arr) internal pure returns (uint256 sum) {
        for (uint i; i < arr.length; i++) {
            sum += arr[i];
        }
    }
}
