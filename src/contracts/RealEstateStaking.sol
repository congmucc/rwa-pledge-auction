// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {RealEstateToken} from "../RealEstateToken.sol";
import {IERC1155Receiver, IERC165} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {OwnerIsCreator} from "@chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {Math} from "@openzeppelin/contracts/utils/math/Math.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract RealEstateStaking is IERC1155Receiver, OwnerIsCreator, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct StakingInfo {
        uint256 amount;
        uint256 startTime;
        uint256 lastClaimTime;
    }

    RealEstateToken internal immutable i_realEstateToken;
    address internal immutable i_usdc;
    AggregatorV3Interface internal s_usdcUsdAggregator;
    uint32 internal s_usdcUsdFeedHeartbeat;

    // Annual yield rate (in basis points, e.g., 500 = 5%)
    uint256 public yieldRateBps = 500;

    // User => TokenId => StakingInfo
    mapping(address => mapping(uint256 => StakingInfo)) public stakingInfo;

    event Staked(address indexed user, uint256 indexed tokenId, uint256 amount);
    event Unstaked(address indexed user, uint256 indexed tokenId, uint256 amount);
    event RewardsClaimed(address indexed user, uint256 indexed tokenId, uint256 amount);
    event YieldRateUpdated(uint256 newYieldRateBps);

    error OnlyRealEstateTokenSupported();
    error InvalidAmount();
    error NothingStaked();
    error TransferFailed();

    constructor(
        address realEstateTokenAddress,
        address usdc,
        address usdcUsdAggregatorAddress,
        uint32 usdcUsdFeedHeartbeat
    ) {
        i_realEstateToken = RealEstateToken(realEstateTokenAddress);
        i_usdc = usdc;
        s_usdcUsdAggregator = AggregatorV3Interface(usdcUsdAggregatorAddress);
        s_usdcUsdFeedHeartbeat = usdcUsdFeedHeartbeat;
    }

    /**
     * @dev Stake tokens
     * @param tokenId The token ID to stake
     * @param amount The amount to stake
     */
    function stake(uint256 tokenId, uint256 amount, bytes calldata data) external nonReentrant {
        if (amount == 0) revert InvalidAmount();

        StakingInfo storage info = stakingInfo[msg.sender][tokenId];
        
        // If this is a new stake, initialize the time
        if (info.amount == 0) {
            info.startTime = block.timestamp;
            info.lastClaimTime = block.timestamp;
        }
        
        // Update staking amount
        info.amount += amount;
        
        // Transfer tokens to this contract
        i_realEstateToken.safeTransferFrom(msg.sender, address(this), tokenId, amount, data);
        
        emit Staked(msg.sender, tokenId, amount);
    }
    
    /**
     * @dev Unstake tokens
     * @param tokenId The token ID to unstake
     * @param amount The amount to unstake
     */
    function unstake(uint256 tokenId, uint256 amount) external nonReentrant {
        StakingInfo storage info = stakingInfo[msg.sender][tokenId];
        
        if (amount == 0) revert InvalidAmount();
        if (info.amount < amount) revert InvalidAmount();
        
        // Claim any pending rewards first
        _claimRewards(msg.sender, tokenId);
        
        // Update staking amount
        info.amount -= amount;
        
        // Transfer tokens back to user
        i_realEstateToken.safeTransferFrom(address(this), msg.sender, tokenId, amount, "");
        
        emit Unstaked(msg.sender, tokenId, amount);
    }
    
    /**
     * @dev Claim rewards for staked tokens
     * @param tokenId The token ID to claim rewards for
     */
    function claimRewards(uint256 tokenId) external nonReentrant {
        _claimRewards(msg.sender, tokenId);
    }
    
    /**
     * @dev Internal function to calculate and distribute rewards
     * @param user The user to claim rewards for
     * @param tokenId The token ID to claim rewards for
     */
    function _claimRewards(address user, uint256 tokenId) internal {
        StakingInfo storage info = stakingInfo[user][tokenId];
        
        if (info.amount == 0) revert NothingStaked();
        
        uint256 timeElapsed = block.timestamp - info.lastClaimTime;
        if (timeElapsed > 0) {
            // Calculate rewards based on staked amount, time elapsed, and yield rate
            uint256 rewards = (info.amount * timeElapsed * yieldRateBps) / (365 days * 10000);
            
            if (rewards > 0) {
                // Update last claim time
                info.lastClaimTime = block.timestamp;
                
                // Transfer USDC rewards to user
                bool success = IERC20(i_usdc).transfer(user, rewards);
                if (!success) revert TransferFailed();
                
                emit RewardsClaimed(user, tokenId, rewards);
            }
        }
    }
    
    /**
     * @dev Calculate pending rewards for a user and token
     * @param user The user address
     * @param tokenId The token ID
     * @return The pending rewards
     */
    function pendingRewards(address user, uint256 tokenId) external view returns (uint256) {
        StakingInfo storage info = stakingInfo[user][tokenId];
        
        if (info.amount == 0) {
            return 0;
        }
        
        uint256 timeElapsed = block.timestamp - info.lastClaimTime;
        return (info.amount * timeElapsed * yieldRateBps) / (365 days * 10000);
    }
    
    /**
     * @dev Update the yield rate (only owner)
     * @param newYieldRateBps The new yield rate in basis points
     */
    function setYieldRate(uint256 newYieldRateBps) external onlyOwner {
        require(newYieldRateBps <= 5000, "Yield rate too high"); // Max 50%
        yieldRateBps = newYieldRateBps;
        emit YieldRateUpdated(newYieldRateBps);
    }

    function getUsdcPriceInUsd() public view returns (uint256) {
        uint80 _roundId;
        int256 _price;
        uint256 _updatedAt;
        try s_usdcUsdAggregator.latestRoundData() returns (
            uint80 roundId,
            int256 price,
            uint256,
            /* startedAt */
            uint256 updatedAt,
            uint80 /* answeredInRound */
        ) {
            _roundId = roundId;
            _price = price;
            _updatedAt = updatedAt;
        } catch {
            revert("Price feed error");
        }

        if (_roundId == 0) revert("Invalid round ID");

        if (_updatedAt < block.timestamp - s_usdcUsdFeedHeartbeat) {
            revert("Stale price feed");
        }

        return uint256(_price);
    }

    function setUsdcUsdPriceFeedDetails(address usdcUsdAggregatorAddress, uint32 usdcUsdFeedHeartbeat)
        external
        onlyOwner
    {
        s_usdcUsdAggregator = AggregatorV3Interface(usdcUsdAggregatorAddress);
        s_usdcUsdFeedHeartbeat = usdcUsdFeedHeartbeat;
    }

    function onERC1155Received(
        address, /*operator*/
        address, /*from*/
        uint256, /*id*/
        uint256, /*value*/
        bytes calldata /*data*/
    ) external view returns (bytes4) {
        if (msg.sender != address(i_realEstateToken)) {
            revert OnlyRealEstateTokenSupported();
        }

        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, /*operator*/
        address, /*from*/
        uint256[] calldata, /*ids*/
        uint256[] calldata, /*values*/
        bytes calldata /*data*/
    ) external view returns (bytes4) {
        if (msg.sender != address(i_realEstateToken)) {
            revert OnlyRealEstateTokenSupported();
        }

        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || interfaceId == type(IERC165).interfaceId;
    }
} 