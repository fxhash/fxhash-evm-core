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
SIGNER_PRIVATE_KEY=
MNEMONIC=
ALICE_ADDRESS=
BOB_ADDRESS=
TREASURY_ADDRESS=
ETHERSCAN_API_KEY=
RPC_URL=
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
npm run deploy
```

8. Seed contracts

```
npm run seed
```
