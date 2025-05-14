// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {RealEstateToken} from "../src/RealEstateToken.sol";

contract DeployScript is Script {
    function run() public returns (RealEstateToken) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 部署参数
        string memory uri = vm.envString("TOKEN_URI");
        address ccipRouter = vm.envAddress("CCIP_ROUTER");
        address linkToken = vm.envAddress("LINK_TOKEN");
        uint64 chainSelector = uint64(vm.envUint("CHAIN_SELECTOR"));
        address functionsRouter = vm.envAddress("FUNCTIONS_ROUTER");

        RealEstateToken realEstateToken = new RealEstateToken(
            uri,
            ccipRouter,
            linkToken,
            chainSelector,
            functionsRouter
        );

        vm.stopBroadcast();
        return realEstateToken;
    }
} 