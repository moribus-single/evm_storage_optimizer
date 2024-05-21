// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {StorageOptimizer} from "./StorageOptimizer.sol";

contract Example {
    uint256 public counter;
    mapping(uint256 => uint256) public data;

    function saveData(
        uint64 a,
        uint64 b,
        uint64 c,
        uint64 d
    ) external returns (uint256) {
        // Create array of values that should be packed
        uint256[] memory values = new uint256[](4);
        values[0] = a;
        values[1] = b;
        values[2] = c;
        values[3] = d;

        // Create bits layout array for packing values
        uint8[] memory bitsLayout = _bitsLayout();

        // Pack values into single slot, save in the storage memory, increase counter
        uint256 _counter = counter;
        data[_counter] = StorageOptimizer.packValues(values, bitsLayout);
        counter++;

        return _counter;
    }

    function loadData(uint256 index) external view returns (uint256[] memory) {
        return StorageOptimizer.unpackValues(data[index], _bitsLayout());
    }

    function _bitsLayout() internal pure returns (uint8[] memory bitsLayout) {
        bitsLayout = new uint8[](4);
        bitsLayout[0] = 64;
        bitsLayout[1] = 64;
        bitsLayout[2] = 64;
        bitsLayout[3] = 64;
    }
}
