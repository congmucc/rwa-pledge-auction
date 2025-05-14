# Real Estate Tokenization Project

This project implements a real estate tokenization system using ERC-1155 tokens with cross-chain capabilities, staking, and auction functionality.

## Features

- ERC-1155 token standard implementation for real estate tokenization
- Cross-chain functionality using Chainlink CCIP
- Real-time price updates using Chainlink Functions
- Real Estate Staking with rewards in USDC
- English Auction mechanism for tokenized real estate
- Automated price updates and management
- Issuer contract for token management

## Project Structure

The project is organized as follows:

```
src/
├── contracts/           # Core application contracts
│   ├── RealEstateStaking.sol      # Staking mechanism for tokenized real estate
│   └── RealEstateAuction.sol      # English auction for tokenized real estate
├── RealEstateToken.sol  # Main ERC-1155 implementation for real estate tokens
├── issuer.sol           # Token issuance management
└── utils/               # Utility contracts and helpers
```

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js and npm
- MetaMask or other Web3 wallet
- Sepolia testnet ETH
- Chainlink Functions subscription

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd rwa-pledge-auction
```

2. Install dependencies:
```bash
forge install
```

## Configuration

1. Create a `.env` file in the project root:
```bash
# 部署账户私钥
PRIVATE_KEY=your_private_key_here

# RPC URLs
SEPOLIA_RPC_URL=your_sepolia_rpc_url

# Etherscan API Key (用于验证合约)
ETHERSCAN_API_KEY=your_etherscan_api_key
```

2. Update the values in `.env` with your actual credentials:
- `PRIVATE_KEY`: Your wallet's private key (keep this secure!)
- `SEPOLIA_RPC_URL`: Your Sepolia RPC URL (from providers like Infura, Alchemy, etc.)
- `ETHERSCAN_API_KEY`: Your Etherscan API key for contract verification

## Compiler Settings

The project uses the following compiler settings (configured in `foundry.toml`):
- Solidity version: 0.8.24
- Optimizer runs: 200
- EVM version: Paris

## Available Commands

The project includes a Makefile with the following commands:

```bash
# 编译合约
make build

# 运行测试
make test

# 运行质押相关测试
make test-staking

# 运行拍卖相关测试
make test-auction

# 清理构建文件
make clean

# 生成测试覆盖率报告
make coverage

# 部署到 Sepolia 测试网
make deploy

# 部署质押和拍卖合约
make deploy-staking-auction

# 使用已部署的 RealEstateToken 部署质押和拍卖合约
make deploy-existing
```

## Deployment Steps

1. **Prepare Environment**
   - Ensure you have sufficient Sepolia ETH in your wallet
   - Verify your `.env` file is properly configured
   - Make sure all dependencies are installed
   - Create and fund a Chainlink Functions subscription

2. **Compile Contracts**
```bash
make build
```

3. **Run Tests**
```bash
make test
```

4. **Deploy to Sepolia**
```bash
make deploy
```

The deployment script will deploy the following contracts:

1. **RealEstateToken**: The main ERC-1155 token for representing fractional real estate ownership
2. **Issuer**: Manages the token issuance process
3. **RealEstateStaking**: Provides staking functionality with USDC rewards
4. **RealEstateAuction**: Implements an English auction mechanism for tokenized real estate

## Contract Verification

The deployment script automatically verifies the contracts on Etherscan. You can view the verified contracts on:
- [Etherscan Sepolia](https://sepolia.etherscan.io/)

## Core Functionality

### RealEstateToken
- ERC-1155 implementation for fractionalized real estate ownership
- Cross-chain transfer capabilities via Chainlink CCIP
- URI management for token metadata

### RealEstateStaking
- Stake real estate tokens and earn USDC rewards
- Configurable yield rates
- Price feed integration via Chainlink oracles

### RealEstateAuction
- English auction mechanism for tokenized real estate
- Automatic time-based auction ending
- Support for bidding, withdrawal, and settlement

## Security Considerations

- Never commit your `.env` file or expose your private key
- Always test thoroughly on testnet before mainnet deployment
- Review all contract interactions and permissions
- Monitor contract events and logs after deployment
- Ensure Chainlink Functions subscription is properly funded



## Support

For support, please open an issue in the repository or contact the developer.
