

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

// import "lib/forge-std/Test.sol";
import "../dreamers.sol";


contract DreamersTest {
    Dreamers dreamer;
    function setUp() public {
        dreamer = new Dreamers();
    }
}