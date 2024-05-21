// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {Example} from "../src/Example.sol";

contract ExampleTests is Test {
    Example exampleContract;

    function setUp() external {
        exampleContract = new Example();
    }

    /// forge-config: default.fuzz.runs = 100000
    function testFuzz_example(uint64 a, uint64 b, uint64 c, uint64 d) public {
        // Create values array
        uint256[] memory values = new uint256[](4);
        values[0] = a;
        values[1] = b;
        values[2] = c;
        values[3] = d;

        // Save the data and get the index of the packed data in the mapping
        uint256 index = exampleContract.saveData(a, b, c, d);

        // Load the data and ensure it is correct
        assertEq(exampleContract.loadData(index), values);
    }
}
