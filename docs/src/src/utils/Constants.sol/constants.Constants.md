# Constants
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/utils/Constants.sol)

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

### PSEUDO_RANDOMIZER

```solidity
string constant PSEUDO_RANDOMIZER = "PSEUDO_RANDOMIZER";
```

### SCRIPTY_RENDERER

```solidity
string constant SCRIPTY_RENDERER = "SCRIPTY_RENDERER";
```

### SPLITS_CONTROLLER

```solidity
string constant SPLITS_CONTROLLER = "SPLITS_CONTROLLER";
```

### SPLITS_FACTORY

```solidity
string constant SPLITS_FACTORY = "SPLITS_FACTORY";
```

### TICKET_REDEEMER

```solidity
string constant TICKET_REDEEMER = "TICKET_REDEEMER";
```

### CLAIM_TYPEHASH

```solidity
bytes32 constant CLAIM_TYPEHASH =
    keccak256("Claim(address token, uint256 reserveId, uint96 nonce, uint256 index, address user)");
```

### SET_BASE_URI_TYPEHASH

```solidity
bytes32 constant SET_BASE_URI_TYPEHASH = keccak256("SetBaseURI(string uri)");
```

### SET_CONTRACT_URI_TYPEHASH

```solidity
bytes32 constant SET_CONTRACT_URI_TYPEHASH = keccak256("SetContractURI(string uri)");
```

### SET_IMAGE_URI_TYPEHASH

```solidity
bytes32 constant SET_IMAGE_URI_TYPEHASH = keccak256("SetImageURI(string uri");
```

### IPFS_URL

```solidity
bytes constant IPFS_URL =
    hex"697066733a2f2f172c151325290607391d2c391b242225180a020b291b260929391d1b31222525202804120031280917120b280400";
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

### TIME_UNLIMITED

```solidity
uint64 constant TIME_UNLIMITED = type(uint64).max;
```

### OPEN_EDITION_SUPPLY

```solidity
uint120 constant OPEN_EDITION_SUPPLY = type(uint120).max;
```

### LOCK_TIME

```solidity
uint128 constant LOCK_TIME = 3600;
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

### METADATA_ROLE

```solidity
bytes32 constant METADATA_ROLE = keccak256("METADATA_ROLE");
```

### MINTER_ROLE

```solidity
bytes32 constant MINTER_ROLE = keccak256("MINTER_ROLE");
```

### MODERATOR_ROLE

```solidity
bytes32 constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
```

### FEE_DENOMINATOR

```solidity
uint96 constant FEE_DENOMINATOR = 10_000;
```

### MAX_ROYALTY_BPS

```solidity
uint96 constant MAX_ROYALTY_BPS = 2500;
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

