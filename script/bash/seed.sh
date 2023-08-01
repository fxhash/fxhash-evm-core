#!/bin/bash
source .env
forge script script/SeedIssuers.s.sol --rpc-url $RPC_URL --mnemonics "$MNEMONIC" --sender $ALICE_ADDRESS --broadcast
sleep 30;
forge script script/SeedTokens.s.sol --rpc-url $RPC_URL --mnemonics "$MNEMONIC" --sender $BOB_ADDRESS --broadcast

#For running against local hardhat node
#forge script script/SeedIssuers.s.sol --rpc-url http://127.0.0.1:8545/ --mnemonics "since swing fatigue addict shallow select derive pepper acoustic midnight code vague" --broadcast
#forge script script/SeedTokens.s.sol --rpc-url http://127.0.0.1:8545/ --mnemonics "since swing fatigue addict shallow select derive pepper acoustic midnight code vague" --broadcast
