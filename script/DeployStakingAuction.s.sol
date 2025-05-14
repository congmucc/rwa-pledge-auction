// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {RealEstateToken} from "../src/RealEstateToken.sol";
import {Issuer} from "../src/issuer.sol";
import {RealEstateStaking as Staking} from "../src/contracts/RealEstateStaking.sol";
import {RealEstateAuction as Auction} from "../src/contracts/RealEstateAuction.sol";

contract DeployStakingAuctionScript is Script {
    // Sepolia 测试网配置
    string constant TOKEN_URI = "";
    address constant CCIP_ROUTER = 0xF694E193200268f9a4868e4Aa017A0118C9a8177;
    address constant LINK_TOKEN = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;
    uint64 constant CHAIN_SELECTOR = 16015286601757825753; // Sepolia
    address constant FUNCTIONS_ROUTER = 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0;
    
    // Staking 配置
    address constant USDC = 0x5425890298aed601595a70AB815c96711a31Bc65;
    address constant USDC_USD_AGGREGATOR = 0x97FE42a7E96640D932bbc0e1580c73E705A8EB73;
    uint32 constant USDC_USD_FEED_HEARTBEAT = 86400;

    function run() public {
        // 判断是使用已经部署的地址还是部署新的合约
        bool useExistingToken = vm.envOr("USE_EXISTING_TOKEN", false);
        address existingTokenAddress = vm.envOr("REAL_ESTATE_TOKEN_ADDRESS", address(0));
        
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // 存储部署的合约地址
        RealEstateToken realEstateToken;
        Issuer issuer;
        
        if (useExistingToken && existingTokenAddress != address(0)) {
            // 使用已部署的 RealEstateToken
            realEstateToken = RealEstateToken(existingTokenAddress);
            console2.log("Using existing RealEstateToken at:", existingTokenAddress);
        } else {
            // 部署 RealEstateToken
            realEstateToken = new RealEstateToken(
                TOKEN_URI,
                CCIP_ROUTER,
                LINK_TOKEN,
                CHAIN_SELECTOR,
                FUNCTIONS_ROUTER
            );
            console2.log("Deployed new RealEstateToken at:", address(realEstateToken));

            // 部署 Issuer
            issuer = new Issuer(
                address(realEstateToken),
                FUNCTIONS_ROUTER
            );
            console2.log("Deployed new Issuer at:", address(issuer));

            // 设置 Issuer
            realEstateToken.setIssuer(address(issuer));
            console2.log("Set Issuer for RealEstateToken");
        }

        // 部署 Staking
        Staking staking = new Staking(
            address(realEstateToken),
            USDC,
            USDC_USD_AGGREGATOR,
            USDC_USD_FEED_HEARTBEAT
        );
        console2.log("Deployed Staking at:", address(staking));

        // 部署 Auction
        Auction auction = new Auction(address(realEstateToken));
        console2.log("Deployed Auction at:", address(auction));

        vm.stopBroadcast();

        // 输出部署地址
        console2.log("\n=== Deployment Summary ===");
        console2.log("RealEstateToken:", address(realEstateToken));
        if (!useExistingToken) console2.log("Issuer:", address(issuer));
        console2.log("Staking:", address(staking));
        console2.log("Auction:", address(auction));
        
        // 输出配置信息
        console2.log("\n=== Configuration Used ===");
        console2.log("USDC Address:", USDC);
        console2.log("USDC/USD Aggregator:", USDC_USD_AGGREGATOR);
        console2.log("USDC/USD Feed Heartbeat:", USDC_USD_FEED_HEARTBEAT);
        
        // 输出接下来的步骤
        console2.log("\n=== Next Steps ===");
        console2.log("1. Verify all contracts on Etherscan");
        console2.log("2. Set up Chainlink Functions subscription if not already done");
        console2.log("3. Fund Staking contract with USDC for rewards");
        console2.log("4. Set approvals for token transfers");
    }
} 