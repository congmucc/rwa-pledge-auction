# Makefile for rwa-pledge-auction Solidity project

.PHONY: all build test clean coverage deploy deploy-staking-auction test-staking test-auction deploy-existing

# 默认目标
all: build

# 编译合约
build:
	forge build

# 运行所有测试
test:
	forge test -vv

# 运行质押相关测试
test-staking:
	forge test -vv --match-test "test_(Staking|Stake|Unstake|ClaimStakingRewards)"

# 运行拍卖相关测试
test-auction:
	forge test -vv --match-test "test_(Auction|Start|PlaceBid|EndAuction)"

# 清理构建文件
clean:
	forge clean

# 生成测试覆盖率报告
coverage:
	forge coverage --report lcov

# 部署到 Sepolia 测试网
deploy:
	forge script script/DeploySepolia.s.sol:DeploySepoliaScript --rpc-url sepolia --broadcast --verify

# 部署质押和拍卖合约
deploy-staking-auction:
	forge script script/DeployStakingAuction.s.sol:DeployStakingAuctionScript --rpc-url sepolia --broadcast --verify

# 使用已部署的 RealEstateToken 部署质押和拍卖合约
deploy-existing:
	forge script script/DeployStakingAuction.s.sol:DeployStakingAuctionScript --rpc-url sepolia --broadcast --verify -vvvv \
	--env-file .env.existing 