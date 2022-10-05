// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "../royalty.sol";


contract RoyaltyTest is Test {
    address tres;
    address comm;
    address owner;
    address inves;

    RoyaltyVault royalty;


    function setUp() public{
        tres = mkaddr("tres");
        comm = mkaddr("comm");
        owner = mkaddr("owner");
        inves = mkaddr("inves");

        vm.prank(owner);
        vm.deal(owner, 20 ether);
        royalty = new RoyaltyVault{value: 10 ether}(tres, comm, inves);
    }
    function testdistributeRoyalty() public{
        vm.prank(owner);
        royalty.distributeRoyalty();
        assertEq(address(royalty).balance, 0);
    }
     function mkaddr(string memory name) public returns (address) {
    address addr = address(uint160(uint256(keccak256(abi.encodePacked(name)))));
    vm.label(addr, name);
    return addr;
  }
}