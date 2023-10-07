# FxHash

## Core Contracts

1. **[FxContractRegistry](src/registries/FxContractRegistry.sol)**: Registry contract that manages all deployed and registered smart contracts by **FxHash**

2. **[FxGenArt721](src/tokens/FxGenArt721.sol)**: `ERC-721` implementation contract that allows for mintng of new tokens, burning of existing tokens and managing of token royalties

3. **[FxIssuerFactory](src/factories/FxIssuerFactory.sol)**: Factory contract that clones the `FxGenArt721` implementation to create new Generative Art Projects

4. **[FxMintTicket721](src/tokens/FxMintTicket721.sol)**: `ERC-721` implementation contract that allows for minting of new tickets, burning of exisiting tickets, and enforcing of harberger taxes over ticket ownership

5. **[FxRoleRegistry](src/registries/FxRoleRegistry.sol)**: Registry contract that implements **[AccessControl](https://docs.openzeppelin.com/contracts/4.x/api/access)** to manage different roles within the system, such as `admin`, `creator`, `minter`, and `moderator`

6. **[FxSplitsFactory](src/factories/FxSplitsFactory.sol)**: Factory contract that creates and manages **[0xSplits](https://docs.splits.org)** contracts for distributing token royalties on primary and secondary sales

7. **[FxTicketFactory](src/factories/FxTicketFactory.sol)**: Factory contract that clones the `FxMintTicket721` implementation to create new Mint Tickets for an existing `FxGenArt721` project

## Periphery Contracts

1. **[DutchAuction](src/minters/DutchAuction.sol)**: Minter contract that mints new `FxGenArt721` and `FxMintTicket721` tokens with a dutch auction pricing mechanism

2. **[FixedPrice](src/minters/FixedPrice.sol)**: Minter contract that mints new `FxGenArt721` and `FxMintTicket721` tokens at a fixed price

3. **[PseudoRandomizer](src/randomizers/PseudoRandomizer.sol)**: Randomizer contract that provides a pseudo-randomness `keccak256` hash using the token ID, the sender's address, the current block number, and the hash of the previous block

4. **[ScriptyRenderer](src/renderers/ScriptyRenderer.sol)**: Renderer contract that generates and builds the metadata of a token fully onchain in `base64` format using **[Scripty.sol](https://int-art.gitbook.io/scripty.sol-v2)**

5. **[TicketRedeemer](src/minters/TicketRedeemer.sol)**: Minter contract that burns an existing `FxMintTicket721` token and mints a new `FxGenArt721` token

## Architechture

```mermaid
graph TD
B[FxGenArt721]--> A[FxRoleRegistry]
C[FxIssuerFactory] --> B
B --> D[FxContractRegistry]
E[FxSplitsFactory]
B --> F[PseudoRandomizer]
B --> G[ScriptyRenderer]
```

## Setup

1. Clone repository

```
git clone https://github.com/fxhash/fxhash-evm-contracts.git
```

2. Create `.env` file in root directory

```
DEPLOYER_PRIVATE_KEY=
ETHERSCAN_API_KEY=
GOERLI_RPC_URL=
MAINNET_RPC_URL=
SEPOLIA_RPC_URL=
```

3. Install dependencies

```
forge install
```

4. Run tests

```
npm run test
```

5. Run prettier

```
npm run prettier
```

6. Deploy contracts

```
forge script script/Deploy.s.sol --rpc-url $GOERLI_RPC_URL --private-key $DEPLOYER_PRIVATE_KEY --verify --etherscan-api-key $ETHERSCAN_API_KEY --broadcast
```
