# Real Estate Tokenization Project

This project implements a real estate tokenization system using ERC-1155 tokens with cross-chain capabilities and Chainlink Functions integration.

## Features

- ERC-1155 token standard implementation
- Cross-chain functionality using Chainlink CCIP
- Real-time price updates using Chainlink Functions
- Automated price updates and management
- Issuer contract for token management

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

# 清理构建文件
make clean

# 生成测试覆盖率报告
make coverage

# 部署到 Sepolia 测试网
make deploy
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

The deployment script will deploy both RealEstateToken and Issuer contracts with the following configuration:

RealEstateToken.sol:
- TOKEN_URI: "" (empty string)
- CCIP_ROUTER: 0xF694E193200268f9a4868e4Aa017A0118C9a8177
- LINK_TOKEN: 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846
- CHAIN_SELECTOR: 16015286601757825753 (Sepolia)
- FUNCTIONS_ROUTER: 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0

Issuer.sol:
- realEstateToken: [Deployed RealEstateToken address]
- functionsRouterAddress: 0xA9d587a00A31A52Ed70D6026794a8FC5E2F5dCb0

## Contract Verification

The deployment script automatically verifies the contracts on Etherscan. You can view the verified contracts on:
- [Etherscan Sepolia](https://sepolia.etherscan.io/)

## Testing

The project includes comprehensive tests for all major functionality:
- Token deployment
- Cross-chain operations
- Price updates
- Access control
- Automation integration
- Issuer contract functionality

Run the tests with:
```bash
make test
```

## Security Considerations

- Never commit your `.env` file or expose your private key
- Always test thoroughly on testnet before mainnet deployment
- Review all contract interactions and permissions
- Monitor contract events and logs after deployment
- Ensure Chainlink Functions subscription is properly funded

## License

MIT License

## Support

For support, please open an issue in the repository or contact the development team.
