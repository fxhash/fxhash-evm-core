# Constants
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/utils/Constants.sol)

### FX_CONTRACT_REGISTRY

```solidity
string constant FX_CONTRACT_REGISTRY = "FX_CONTRACT_REGISTRY";
```

### FX_GEN_ART_721

```solidity
string constant FX_GEN_ART_721 = "FX_GEN_ART_721";
```

### FX_ISSUER_FACTORY

```solidity
string constant FX_ISSUER_FACTORY = "FX_ISSUER_FACTORY";
```

### FX_MINT_TICKET_721

```solidity
string constant FX_MINT_TICKET_721 = "FX_MINT_TICKET_721";
```

### FX_ROLE_REGISTRY

```solidity
string constant FX_ROLE_REGISTRY = "FX_ROLE_REGISTRY";
```

### FX_TICKET_FACTORY

```solidity
string constant FX_TICKET_FACTORY = "FX_TICKET_FACTORY";
```

### DUTCH_AUCTION

```solidity
string constant DUTCH_AUCTION = "DUTCH_AUCTION";
```

### FIXED_PRICE

```solidity
string constant FIXED_PRICE = "FIXED_PRICE";
```

### IPFS_RENDERER

```solidity
string constant IPFS_RENDERER = "IPFS_RENDERER";
```

### PSEUDO_RANDOMIZER

```solidity
string constant PSEUDO_RANDOMIZER = "PSEUDO_RANDOMIZER";
```

### TICKET_REDEEMER

```solidity
string constant TICKET_REDEEMER = "TICKET_REDEEMER";
```

### CLAIM_TYPEHASH

```solidity
bytes32 constant CLAIM_TYPEHASH =
    keccak256("Claim(address token,uint256 reserveId,uint96 nonce,uint256 index,address user)");
```

### SET_BASE_URI_TYPEHASH

```solidity
bytes32 constant SET_BASE_URI_TYPEHASH = keccak256("SetBaseURI(bytes uri,uint96 nonce)");
```

### SET_ONCHAIN_DATA_TYPEHASH

```solidity
bytes32 constant SET_ONCHAIN_DATA_TYPEHASH = keccak256("SetOnchainData(bytes data,uint96 nonce)");
```

### SET_PRIMARY_RECEIVER_TYPEHASH

```solidity
bytes32 constant SET_PRIMARY_RECEIVER_TYPEHASH = keccak256("SetPrimaryReceiver(address receiver,uint96 nonce)");
```

### SET_RENDERER_TYPEHASH

```solidity
bytes32 constant SET_RENDERER_TYPEHASH = keccak256("SetRenderer(address renderer,uint96 nonce)");
```

### IPFS_URL

```solidity
bytes constant IPFS_URL =
    hex"697066733a2f2f172c151325290607391d2c391b242225180a020b291b260929391d1b31222525202804120031280917120b280400";
```

### METADATA_ENDPOINT

```solidity
string constant METADATA_ENDPOINT = "/metadata.json";
```

### THUMBNAIL_ENDPOINT

```solidity
string constant THUMBNAIL_ENDPOINT = "/thumbnail.json";
```

### UNINITIALIZED

```solidity
uint8 constant UNINITIALIZED = 0;
```

### FALSE

```solidity
uint8 constant FALSE = 1;
```

### TRUE

```solidity
uint8 constant TRUE = 2;
```

### LOCK_TIME

```solidity
uint32 constant LOCK_TIME = 3600;
```

### TIME_UNLIMITED

```solidity
uint64 constant TIME_UNLIMITED = type(uint64).max;
```

### OPEN_EDITION_SUPPLY

```solidity
uint120 constant OPEN_EDITION_SUPPLY = type(uint120).max;
```

### ADMIN_ROLE

```solidity
bytes32 constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
```

### BANNED_USER_ROLE

```solidity
bytes32 constant BANNED_USER_ROLE = keccak256("BANNED_USER_ROLE");
```

### CREATOR_ROLE

```solidity
bytes32 constant CREATOR_ROLE = keccak256("CREATOR_ROLE");
```

### MINTER_ROLE

```solidity
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
```

### MODERATOR_ROLE

```solidity
bytes32 constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
```

### SIGNER_ROLE

```solidity
bytes32 constant SIGNER_ROLE = keccak256("SIGNER_ROLE");
```

### ALLOCATION_DENOMINATOR

```solidity
uint32 constant ALLOCATION_DENOMINATOR = 1_000_000;
```

### FEE_DENOMINATOR

```solidity
uint96 constant FEE_DENOMINATOR = 10_000;
```

### MAX_ROYALTY_BPS

```solidity
uint96 constant MAX_ROYALTY_BPS = 2500;
```

### SPLITS_MAIN

```solidity
address constant SPLITS_MAIN = 0x2ed6c4B5dA6378c7897AC67Ba9e43102Feb694EE;
```

### AUCTION_DECAY_RATE

```solidity
uint256 constant AUCTION_DECAY_RATE = 200;
```

### DAILY_TAX_RATE

```solidity
uint256 constant DAILY_TAX_RATE = 27;
```

### MINIMUM_PRICE

```solidity
uint256 constant MINIMUM_PRICE = 0.001 ether;
```

### ONE_DAY

```solidity
uint256 constant ONE_DAY = 86_400;
```

### SCALING_FACTOR

```solidity
uint256 constant SCALING_FACTOR = 10_000;
```

### TEN_MINUTES

```solidity
uint256 constant TEN_MINUTES = 600;
```

