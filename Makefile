# Makefile for rwa-pledge-auction Solidity project

.PHONY: all build test clean coverage deploy

# 默认目标
all: build

# 编译合约
build:
	forge build

# 运行所有测试
test:
	forge test -vv

# 清理构建文件
clean:
	forge clean

# 生成测试覆盖率报告
coverage:
	forge coverage --report lcov

# 部署到 Sepolia 测试网
deploy:
	forge script script/DeploySepolia.s.sol:DeploySepoliaScript --rpc-url sepolia --broadcast --verify 