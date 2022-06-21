

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "lib/forge-std/src/Test.sol";
import "../dreamers.sol";


contract DreamersTest is Test {
    Dreamers dreamer;
    function setUp() public {
        dreamer = new Dreamers();
    }
}