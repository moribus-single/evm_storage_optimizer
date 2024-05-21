// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

/**
 * @title Library for packing multiple values in one storage slot (uint256)
 */
library StorageOptimizer {
    /// Solidity maximum amount of bits allowed for unsigned integer
    uint16 constant MAX_BITS = 256;

    /**
     * Pack array of provided values into single uint256 slot and use specified amount of bits for
     * each value.
     *
     * @param values Array of values that should be packed into single uint256 slot
     * @param bits Array of bits used by values that should be packed
     */
    function packValues(
        uint256[] memory values,
        uint8[] memory bits
    ) external pure returns (uint256 outputSlot) {
        if (values.length != bits.length) {
            revert();
        }

        // Sum of all bits should be less or equal than maximum allowed in Solidity uint256
        if (_sum(bits) > MAX_BITS) {
            revert();
        }

        // Packing the values into a slot
        for (uint8 i; i < values.length; i++) {
            outputSlot = packValue(outputSlot, values[i], bits[i]);
        }
    }

    /**
     * Unpack the values from provided slot that are using provided amount of bits
     *
     * @param inputSlot Slot from which values should be unpacked
     * @param bits Array of bits used by values that should be unpacked
     */
    function unpackValues(
        uint256 inputSlot,
        uint8[] memory bits
    ) external pure returns (uint256[] memory values) {
        // Sum of all bits should be less or equal than maximum allowed in Solidity uint256
        if (_sum(bits) > MAX_BITS) {
            revert();
        }

        // Initialize values variable as array with the same length as bits array
        values = new uint256[](bits.length);

        // Unpacking values from the slot
        for (uint8 i; i < bits.length; i++) {
            uint8 bitsAmount = bits[bits.length - 1 - i];
            values[bits.length - 1 - i] = unpackValue(inputSlot, bitsAmount);

            // Shift to the right
            assembly {
                inputSlot := shr(bitsAmount, inputSlot)
            }
        }
    }

    /**
     * Save the value in the provided uint256 slot using specified amount of bits
     *
     * @param inputSlot Slot where provided value should be saved
     * @param value Value that should be saved in the inputSlot
     * @param bits Amount of bits that value can use
     */
    function packValue(
        uint256 inputSlot,
        uint256 value,
        uint8 bits
    ) public pure returns (uint256 outputSlot) {
        // Build the mask
        uint256 mask = _buildMask(bits);

        // Save all the old bits and save a new value
        assembly {
            let extractedValue := and(mask, value)
            outputSlot := or(shl(bits, inputSlot), extractedValue)
        }
    }

    /**
     * Extract specified amount of bits from the provided slot using binary mask
     *
     * @param inputSlot Slot from which value should be extracted
     * @param bits Amount of bits that should be extracted
     */
    function unpackValue(
        uint256 inputSlot,
        uint8 bits
    ) public pure returns (uint256 value) {
        // Build the mask
        uint256 mask = _buildMask(bits);

        // Extract the value from the slot
        assembly {
            value := and(mask, inputSlot)
        }
    }

    /**
     * Build the binary mask with provided amount of bits
     *
     * @param bits Amount of bits for the mask
     */
    function _buildMask(uint8 bits) internal pure returns (uint256 mask) {
        assembly {
            // mask = 2 ** bits - 1
            mask := sub(exp(0x2, bits), 1)
        }
    }

    /**
     * Calculate sum of all numbers in the provided arrayz
     * @param arr Array for which we need to calculate sum of all of the elements
     */
    function _sum(uint8[] memory arr) internal pure returns (uint16 sum) {
        for (uint8 i; i < arr.length; i++) {
            sum += arr[i];
        }
    }
}
