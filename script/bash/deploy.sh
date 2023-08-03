#!/bin/bash
source .env
forge script script/DeployScript.s.sol --rpc-url $RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
