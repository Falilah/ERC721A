

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;

import "forge-std/Test.sol";
import "../DRM.sol";


contract DreamersTest is Test {
    DreamerBay dreamer;
    address bob = address(0x1);
    address alice =address (0x2);
    address mary =address( 0x3);
    address rose = address(0x4);

    function setUp() public {
        dreamer = new DreamerBay();
        dreamer.setBaseURI("ipfs://QmcKBFgWTEayKPrKhaQhz4cmAqjzzhncztpyJS44YyF4dv/");

    }

    // function testendpRESaleAndSetupPublicSale() public{
    //     dreamer.endPreSaleAndSetupPublicSale(1656418579, 5 ether, 5);
    //     // assertEq(dreamer.publicSaleProps.price, 5 ether);

        
    // }
//// ipfs://QmcKBFgWTEayKPrKhaQhz4cmAqjzzhncztpyJS44YyF4dv/

    function testPublicSale() public{
        vm.startPrank(bob);
        dreamer = new DreamerBay();
        dreamer.endPreSaleAndSetupPublicSale(1756421501, 2 ether, 5);
        dreamer.setBaseURI("ipfs://QmcKBFgWTEayKPrKhaQhz4cmAqjzzhncztpyJS44YyF4dv/");

        deal(bob, 20 ether);
        vm.warp(1756421907);

        dreamer.publicSaleMint{value:5 ether}(2);

        uint val = dreamer.totalSupply();
        assertEq(val, 2);
        // dreamer.RevealNFT(true);
        string memory name = dreamer.tokenURI(1);
        assertEq(name,"");

        uint minted = dreamer.numberMinted(bob);
         assertEq(minted, 2);   
    
        assertEq(bob.balance, 16 ether);
        assertEq(address(dreamer).balance, 4 ether);


        dreamer.withdrawMoney();
        assertEq(address(dreamer).balance, 0 ether);
        assertEq(bob.balance, 20 ether);
        



        vm.stopPrank();



    }
    function testTeamMint() public {
        dreamer.addTeamMember(alice, 10);
        dreamer.addTeamMember(bob, 10);
        dreamer.addTeamMember(mary, 10);
        vm.startPrank(bob);
        dreamer.teamMint();
        assertEq(dreamer.numberMinted(bob), 10);
        vm.stopPrank();
         vm.startPrank(alice);
        dreamer.teamMint();
        assertEq(dreamer.numberMinted(alice), 10);
        string memory val = dreamer.tokenURI(5);
        assertEq(val, "");
        vm.expectRevert("teamMint: No teamNFT assigned");
        dreamer.teamMint();
        vm.expectRevert("Ownable: caller is not the owner");
        dreamer.addTeamMember(rose, 10);
        vm.stopPrank();
        vm.startPrank(rose);
        vm.expectRevert("teamMint: No teamNFT assigned");
        dreamer.teamMint();
        vm.stopPrank();






    }

    function testpresaleMint() public {

        bytes32[] memory proof =  new bytes32[](2);
        proof[0] =
  0x5b70e80538acdabd6137353b0f9d8d149f4dba91e8be2e7946e409bfdbe685b9;
  proof[1] =0x70e08b2550044020237f234427d6309de9db2c023ac9024ed06f96beb044bd42;
        

        dreamer.setPresaleProps(0x73460d5b8b8b16dec2d9b062b0209a37f78d6c3a7850b12737fef77fc0b638db, 1756421907, 0.08 ether,5);
         vm.startPrank(bob);
         deal(bob, 20 ether);
        vm.warp(1756421907);
        dreamer.presaleMint{value:10 ether}(proof, 4);
        assertEq(dreamer.numberMinted(bob), 4);
        uint val = dreamer.totalSupply();
        assertEq(val, 4);
        vm.stopPrank();
        assertEq(dreamer.numberMinted(bob), 4);

    }



   
}