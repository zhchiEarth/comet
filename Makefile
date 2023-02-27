# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
# change ETH_RPC_URL to another one (e.g., FTM_RPC_URL) for different chains
# FORK_URL := ${BSC_RPC_URL}

# For deployments. Add all args without a comma
# ex: 0x316..FB5 "Name" 10
# constructor-args := 

# build  :; forge build
# test   :; forge test -vv --fork-url ${FORK_URL} --etherscan-api-key ${ETHERSCAN_API_KEY}
# trace   :; forge test -vvv --fork-url ${FORK_URL} --etherscan-api-key ${ETHERSCAN_API_KEY}
# test-contract :; forge test -vv --fork-url ${FORK_URL} --match-contract $(contract) --etherscan-api-key ${ETHERSCAN_API_KEY}
# trace-contract :; forge test -vvv --fork-url ${FORK_URL} --match-contract $(contract) --etherscan-api-key ${ETHERSCAN_API_KEY}
# deploy	:; forge create --rpc-url ${FORK_URL} --constructor-args ${constructor-args} --private-key ${PRIV_KEY} src/Strategy.sol:Strategy --etherscan-api-key ${ETHERSCAN_API_KEY} --verify
# # local tests without fork
# test-local  :; forge test
# trace-local  :; forge test -vvv
# clean  :; forge clean
# snapshot :; forge snapshot
deploy-bsc_testnet-configurator :; forge script forge/script/Configurator.s.sol:ConfiguratorScript --rpc-url  --rpc-url ${BSC_TESTNET_RPC_URL}  --broadcast --etherscan-api-key ${BSC_API_KEY}  --verify
deploy-avalanche_fuji-configurator :; forge script forge/script/Configurator.s.sol:ConfiguratorScript --rpc-url  --rpc-url ${AVALANCHE_FUJI_RPC_URL}  --broadcast --etherscan-api-key ${AVALANCHE_API_KEY}  --verify
deploy-polygon_mumbai-configurator :; forge script forge/script/Configurator.s.sol:ConfiguratorScript --rpc-url  --rpc-url ${POLYGON_MUMBAI_RPC_URL}  --broadcast --etherscan-api-key ${POLYGON_API_KEY}  --verify

deploy-bsc_testnet-comet :; forge script Comet.s.sol:CometScript --rpc-url  --rpc-url ${BSC_TESTNET_RPC_URL}  --broadcast --etherscan-api-key ${BSC_API_KEY}  --verify
deploy-avalanche_fuji-comet :; forge script Comet.s.sol:CometScript --rpc-url  --rpc-url ${AVALANCHE_FUJI_RPC_URL}  --broadcast --etherscan-api-key ${AVALANCHE_API_KEY}  --verify
deploy-polygon_mumbai-comet :; forge script Comet.s.sol:CometScript --rpc-url  --rpc-url ${POLYGON_MUMBAI_RPC_URL}  --broadcast --etherscan-api-key ${POLYGON_API_KEY}  --verify


# local
deploy-local-token :; forge script forge/script/Token.s.sol:TokenScript --rpc-url http://127.0.0.1:8545 --private-key ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv
deploy-local-configurator :; forge script forge/script/Configurator.s.sol:ConfiguratorScript --rpc-url http://127.0.0.1:8545 --private-key ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv
deploy-local-comet :; forge script forge/script/Comet.s.sol:CometScript --rpc-url http://127.0.0.1:8545 --private-key ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast -vvvv


