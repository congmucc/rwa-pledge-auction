// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {RealEstateToken} from "../src/RealEstateToken.sol";

contract DeploySepoliaScript is Script {
    // Sepolia 测试网配置
    string constant TOKEN_URI = "";
    address constant CCIP_ROUTER = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
    address constant LINK_TOKEN = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    uint64 constant CHAIN_SELECTOR = 16015286601757825753; // Sepolia 的 Chain Selector
    address constant FUNCTIONS_ROUTER = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;

    function run() public returns (RealEstateToken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        RealEstateToken realEstateToken = new RealEstateToken(
            TOKEN_URI,
            CCIP_ROUTER,
            LINK_TOKEN,
            CHAIN_SELECTOR,
            FUNCTIONS_ROUTER
        );

        vm.stopBroadcast();
        return realEstateToken;
    }
} 