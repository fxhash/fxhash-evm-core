# FXHASH EVM contracts

This is a set of two Solidity smart contracts, `GenTk` and `GenTkProject`, which allows the minting of generative tokens. These contracts allow for the creation and management of unique tokens (GenTks) associated with specific projects.

## GenTk Contract

The `GenTk` contract is an ERC721 compliant contract that represents individual GenTk tokens. It inherits from `ERC721URIStorage`, providing the ability to assign and store metadata URIs for each token. It also implements various other interfaces such as `AccessControl`, `RoyaltiesV2`, `IERC2981`, and `IGenTk`.

### Features and Functionality

- GenTk tokens are unique, non-fungible tokens.
- The contract supports the assignment and retrieval of metadata URIs for each token.
- It implements role-based access control, allowing for different levels of administration.
- GenTk tokens can have royalty beneficiaries, and royalty calculations can be performed based on the sale price of a token.
- The contract can provide the royalty information for a specific token.
- It supports batch minting of GenTk tokens associated with a specific project.

### Roles

- DEFAULT_ADMIN_ROLE: This role is granted to the contract deployer and allows for general administrative functions.
- FXHASH_ADMIN: This role is granted to specific addresses and represents higher-level administrative access.

### Functions

- `supportsInterface`: Overrides the `supportsInterface` function to include support for additional interfaces.
- `getRaribleV2Royalties`: Retrieves the royalty configuration for a GenTk token from the associated GenTkProject contract.
- `royaltyInfo`: Calculates and returns the royalty information for a GenTk token based on its sale price.
- `assignMetadata`: Allows the contract owner (FXHASH_ADMIN) to assign metadata URI for a GenTk token.
- `setDefaultURI`: Allows the contract owner (FXHASH_ADMIN) to set a default metadata URI for GenTk tokens.
- `grantAdminRole` and `revokeAdminRole`: Grant or revoke the DEFAULT_ADMIN_ROLE to/from an address.
- `grantFxHashAdminRole` and `revokeFxHashAdminRole`: Grant or revoke the FXHASH_ADMIN role to/from an address.
- `setGenTkProject`: Sets the address of the associated GenTkProject contract.
- `getDefaultURI`: Retrieves the default metadata URI.
- `mintGenTks`: Allows the associated GenTkProject contract to batch mint GenTk tokens.

## GenTkProject Contract

The `GenTkProject` contract represents a specific project associated with GenTk tokens. It inherits from `ERC721URIStorage` and implements various interfaces such as `AccessControl`, `RoyaltiesV2`, `AbstractRoyalties`, `IERC2981`, and `IGenTkProject`.

### Features and Functionality

- The contract allows for the creation and management of GenTk projects, each associated with a unique token.
- GenTkProject tokens are ERC721 compliant and have associated metadata URIs.
- The contract implements role-based access control for administrative functions.
- It supports the configuration and retrieval of royalty information for each GenTkProject token.
- GenTk tokens associated with a project can be minted, subject to project-specific conditions.

### Roles

- DEFAULT_ADMIN_ROLE: This role is granted to the contract deployer and allows for general administrative functions.
- FXHASH_ADMIN: This role is granted to specific addresses and represents higher-level administrative access.

### Functions

- `supportsInterface`: Overrides the `supportsInterface` function to include support for additional interfaces.
- `getRaribleV2Royalties`: Retrieves the royalty configuration for a GenTkProject token.
- `royaltyInfo`: Calculates and returns the royalty information for a GenTkProject token based on its sale price.
- `_onRoyaltiesSet`: Internal function called when royalty configuration is set for a GenTkProject token.
- `grantFxHashAdminRole` and `revokeFxHashAdminRole`: Grant or revoke the FXHASH_ADMIN role to/from an address.
- `grantAdminRole` and `revokeAdminRole`: Grant or revoke the DEFAULT_ADMIN_ROLE to/from an address.
- `setGenTk`: Sets the address of the associated GenTk contract.
- `getGenTk`: Retrieves the address of the associated GenTk contract.
- `createProject`: Creates a new GenTkProject by specifying project details such as editions, price, opening time, royalties, and project URI.
- `mint`: Mints a GenTk token associated with a specific GenTkProject token. It verifies project availability, sale start time, payment value, and distributes royalties.

## Logic Flow

The GenTk and GenTkProject contracts work together to enable the creation and management of unique GenTk tokens associated with specific projects. Here's a high-level overview of the logic flow:

1. The GenTkProject contract is deployed, and the contract owner (FXHASH_ADMIN) can grant the FXHASH_ADMIN and DEFAULT_ADMIN_ROLE to specific addresses.
2. GenTkProject tokens are created using the `createProject` function. Each project is associated with a unique token and has various properties such as editions, price, opening time, royalties, and project URI.
3. The associated GenTk contract address is set using the `setGenTk` function, ensuring that it implements the IGenTk interface.
4. Once a GenTkProject token is created, it can have royalty configurations set using the `setRoyalties` function.
5. GenTk tokens can be minted by calling the `mint` function of the GenTkProject contract. The function verifies project availability, sale start time, and payment value. It also calculates and distributes royalties to the specified beneficiaries.
6. GenTk tokens can have their metadata assigned using the `assignMetadata` function by the contract owner (FXHASH_ADMIN).
7. Additional administrative actions can be performed, such as granting/rejecting admin roles and setting default metadata URIs.

This logic flow allows for the creation and management of GenTk tokens associated with specific projects, including the calculation and distribution of royalties.
