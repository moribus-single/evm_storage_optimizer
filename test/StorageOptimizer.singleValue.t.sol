// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {StorageOptimizer} from "../src/StorageOptimizer.sol";

/**
 * @title Tests for packing single value
 */
contract FuzzingTestsSingleValue is Test {
    /**
     * Simple test to check that packing some value works properly
     */
    function test_packValue() public pure {
        // Initialize params
        uint256 inputSlot = 1;
        uint256 value = 872;
        uint8 bits = 10;

        // Pack the value and check the result
        uint256 packedSlot = StorageOptimizer.packValue(inputSlot, value, bits);
        assertEq(packedSlot, 2 ** bits + value);
    }

    /**
     * Simple test to check that unpacking packed value works properly
     */
    function test_unpackValue() public pure {
        // Initialize params
        uint256 value = 872;
        uint8 bits = 10;
        uint256 packedSlot = 2 ** bits + value;

        // Unpacking the value and check the result
        uint256 unpackedValue = StorageOptimizer.unpackValue(packedSlot, bits);
        assertEq(value, unpackedValue);
    }

    /**
     * Fuzzing test to check that packing & unpacking works properly on different parameters.
     *
     * @param inputSlot Input slot that is fuzzed
     */
    /// forge-config: default.fuzz.runs = 30000
    function testFuzz_fuzzingParameters(
        uint256 inputSlot,
        uint256 value,
        uint8 bits
    ) public pure {
        // assume we have enough bits to pack the value
        vm.assume(bits <= 256);
        vm.assume(value <= 2 ** bits - 1);

        // inputSlot value should be less than 2^(256 - bits) to correctly store the values
        if (bits > 0) {
            vm.assume(inputSlot <= 2 ** (256 - bits) - 1);
        }

        // packing and unpacking the value
        uint256 packedSlot = StorageOptimizer.packValue(inputSlot, value, bits);
        uint256 unpackedValue = StorageOptimizer.unpackValue(packedSlot, bits);
        assertEq(value, unpackedValue);
    }
}
