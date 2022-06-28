

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "../DRM.sol";


contract DreamersTest is Test {
    DRM dreamer;
    address bob = address(0x1);
    address alice =address (0x2);
    address mary =address( 0x3);
    // address rose = 0x4;

    function setUp() public {
        dreamer = new DRM();
    }

    function testendpRESaleAndSetupPublicSale() public{
        dreamer.endpRESaleAndSetupPublicSale(1656418579, 5, 5);
        
    }

    function testPublicSale() public{
        dreamer.endpRESaleAndSetupPublicSale(1756421501, 2, 5);
        dreamer.setBaseURI("hsjkak");
        // asserEq(baseTokenURI(), "hsjkak"); 
        // dreamer.tokenURI(0);
        vm.startPrank(bob);
        deal(bob, 2000000000000000000000);
        vm.warp(1756421901);
        dreamer.publicSaleMint{value:5}(2);
        vm.stopPrank();
    }
}