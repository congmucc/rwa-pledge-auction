// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {RealEstateToken} from "../src/RealEstateToken.sol";
import {RealEstatePriceDetails} from "../src/RealEstatePriceDetails.sol";

contract TokenizationTest is Test {
    RealEstateToken public realEstateToken;
    address public owner;
    address public user1;
    address public user2;
    
    // Test constants
    string constant TOKEN_URI = "ipfs://QmTest";
    address constant CCIP_ROUTER = address(0x1234);
    address constant LINK_TOKEN = address(0x5678);
    uint64 constant CHAIN_SELECTOR = 1;
    address constant FUNCTIONS_ROUTER = address(0x9ABC);
    
    function setUp() public {
        owner = makeAddr("owner");
        user1 = makeAddr("user1");
        user2 = makeAddr("user2");
        
        vm.startPrank(owner);
        realEstateToken = new RealEstateToken(
            TOKEN_URI,
            CCIP_ROUTER,
            LINK_TOKEN,
            CHAIN_SELECTOR,
            FUNCTIONS_ROUTER
        );
        vm.stopPrank();
    }

    function test_Deployment() public {
        assertEq(address(realEstateToken.owner()), owner);
    }

    function test_SetAutomationForwarder() public {
        address automationForwarder = makeAddr("automationForwarder");
        
        vm.startPrank(owner);
        realEstateToken.setAutomationForwarder(automationForwarder);
        vm.stopPrank();
        
        // Test that non-owner cannot set automation forwarder
        vm.startPrank(user1);
        vm.expectRevert();
        realEstateToken.setAutomationForwarder(automationForwarder);
        vm.stopPrank();
    }

    function test_UpdatePriceDetails() public {
        string memory tokenId = "123";
        uint64 subscriptionId = 1;
        uint32 gasLimit = 300000;
        bytes32 donID = bytes32("0x1234");
        
        // Set automation forwarder
        address automationForwarder = makeAddr("automationForwarder");
        vm.startPrank(owner);
        realEstateToken.setAutomationForwarder(automationForwarder);
        
        // Test owner can update price details
        bytes32 requestId = realEstateToken.updatePriceDetails(tokenId, subscriptionId, gasLimit, donID);
        assertTrue(requestId != bytes32(0));
        
        // Test automation forwarder can update price details
        vm.stopPrank();
        vm.startPrank(automationForwarder);
        requestId = realEstateToken.updatePriceDetails(tokenId, subscriptionId, gasLimit, donID);
        assertTrue(requestId != bytes32(0));
        
        // Test that unauthorized users cannot update price details
        vm.stopPrank();
        vm.startPrank(user1);
        vm.expectRevert();
        realEstateToken.updatePriceDetails(tokenId, subscriptionId, gasLimit, donID);
        vm.stopPrank();
    }

    function test_GetPriceDetails() public {
        uint256 tokenId = 1;
        
        // Initially price details should be empty
        RealEstatePriceDetails.PriceDetails memory details = realEstateToken.getPriceDetails(tokenId);
        assertEq(details.listPrice, 0);
        assertEq(details.originalListPrice, 0);
        assertEq(details.taxAssessedValue, 0);
    }

    function test_CrossChainFunctionality() public {
        // Test cross-chain minting
        uint256 tokenId = 1;
        uint256 amount = 100;
        bytes memory data = "";

        vm.startPrank(owner);
        realEstateToken.mint(owner, tokenId, amount, data, TOKEN_URI);
        assertEq(realEstateToken.balanceOf(owner, tokenId), amount);
        
        // Test cross-chain burning
        realEstateToken.burn(owner, tokenId, amount);
        assertEq(realEstateToken.balanceOf(owner, tokenId), 0);
        vm.stopPrank();
    }
}