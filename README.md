# FXHASH EVM Contracts

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
npm ci
forge install
```

4. Run prettier

```
npm run prettier
```

5. Run hardhat tests

```
npm run test
```

6. Run foundry tests

```
forge test
```

7. Deploy contracts

```
forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
```

## Architecture

<img src="images/architecture.svg">
