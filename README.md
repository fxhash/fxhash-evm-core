# FxHash EVM Contracts

## Setup

1. Clone repository

```
git clone git@github.com:fxhash/fxhash-evm-contracts.git
```

2. Create `.env` file in root directory

```
COIN_MARKET_CAP_API_KEY=
DEPLOYER_PRIVATE_KEY=
ETHERSCAN_API_KEY=
GOERLI_RPC_URL=
MAINNET_RPC_URL=
```

3. Install dependencies

```
forge install
```

4. Run tests

```
forge test
```

5. Run formatter

```
forge fmt
```

6. Deploy contracts

```
forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
```
