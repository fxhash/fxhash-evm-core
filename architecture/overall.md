# Overall architecture diagram

## Gates (Reserves & Pricings)

> The Gates are used as entry points to the Issuer, they act as a filter for accessing a mint. In the next architecture diagrams, Gates will be referred to as Gates; the concept englobes all the Pricing & Reserve mechanism which are abstracted from the rest of the application.

### Design

Reserves & Pricing have the following options:

- Reserves
  - Public (fully open)
  - Mint Pass
  - Access List
- Pricings
  - Fixed
  - Dutch Auction

To optimize gas & provide a simple entry point for the minting interface, a composability pattern will be used, where there will be one contract for every combination of Reserve & Pricing possible:

| Pricings \ Reserves | Public              | Mint Pass             | Access List             |
| ------------------- | ------------------- | --------------------- | ----------------------- |
| **Fixed**           | Public_Fixed        | MintPass_Fixed        | AccessList_Fixed        |
| **Dutch Auction**   | Public_DutchAuction | MintPass_DutchAuction | AccessList_DutchAuction |

### Diagram

```mermaid
classDiagram
  %% deps
  Gate <|-- Reserve : inherits
  Gate <|-- Pricing : inherits
  Reserve <|-- ReserveMintPass : inherits
  Reserve <|-- ReserveAccessList : inherits
  Reserve <|-- ReservePublic : inherits
  Pricing <|-- PricingFixed : inherits
  Pricing <|-- PricingDutchAuction : inherits

  %% composition
  ReserveMintPass *-- ReserveMintPass_PricingFixed : composed
  PricingFixed *-- ReserveMintPass_PricingFixed : composed
  ReserveMintPass *-- ReserveMintPass_PricingDutchAuction : composed
  PricingDutchAuction *-- ReserveMintPass_PricingDutchAuction : composed
  ReservePublic *-- ReservePublic_PricingFixed : composed
  PricingFixed *-- ReservePublic_PricingFixed : composed
  ReservePublic *-- ReservePublic_PricingDutchAuction : composed
  PricingDutchAuction *-- ReservePublic_PricingDutchAuction : composed
  ReserveAccessList *-- ReserveAccessList_PricingFixed : composed
  PricingFixed *-- ReserveAccessList_PricingFixed : composed
  ReserveAccessList *-- ReserveAccessList_PricingDutchAuction : composed
  PricingDutchAuction *-- ReserveAccessList_PricingDutchAuction : composed

  class Gate {
    <<interface>>
    + pass()
  }

  class Reserve {
    <<interface>>
    - amount
  }
  class ReserveMintPass {
    - mint_pass_contract
    + pass(bytes mint_pass_details, bytes32 signature)
  }
  class ReserveAccessList {
    - merke_root
    - tracking
    + pass(bytes32 merkle_proof)
  }
  class ReservePublic {
  }

  class Pricing {
    <<interface>>
  }
  class PricingFixed {
    - opening_time
    - price
  }
  class PricingDutchAuction {
    - opening_time
    - levels
    - time_decrement
  }

  class ReservePublic_PricingFixed {
  }
  class ReservePublic_PricingDutchAuction {
  }
  class ReserveAccessList_PricingFixed {
  }
  class ReserveAccessList_PricingDutchAuction {
  }
  class ReserveMintPass_PricingFixed {
  }
  class ReserveMintPass_PricingDutchAuction {
  }
```

## Seed generation: Randomizer

To each GenTk will be associated a Randomizer implementation which will be responsible for handling the generation & reveal of the seed.

### Class diagram

```mermaid
classDiagram
  Randomizer <|-- OnchainPseudoRandomizer: inherits
  GenTk --> Randomizer : 1. generate()
  Randomizer --> GenTk : 2. set_seed()

  class GenTk {
    <<interface>>
    + mint()
    + set_seed(bytes32 seed)
  }

  class Randomizer {
    <<interface>>
    + generate(tokenId, minter)
  }

  class OnchainPseudoRandomizer {
  }
```

### Sequence diagram

```mermaid
sequenceDiagram
  actor User
  participant GenTk
  participant Randomizer

  User->>GenTk: mint()
  GenTk->>Randomizer: generate(): request for seed generation
  activate Randomizer
  Randomizer-)Randomizer: internal process for generating seed
  Randomizer--)GenTk: setSeed()
  deactivate Randomizer
```

The implementation is agnostic of the synchronicity process of the reveal mechanism; the GenTk makes a request for a seed and expects the Randomizer to eventually resolve with a seed down the line.

## [WIP] Project architecture

> This architecture provides a high level overview; it doesn't factor the creation pattern nor the implementation pattern of the contracts.

```mermaid
classDiagram
  %% inheritance
  Issuer <|-- IssuerBase : inherits
  Issuer <|-- IssuerParams : inherits
  ERC721 <|-- GenTk : implements
  ERC721 <|-- Issuer_Tickets : implements
  %% comms
  User "1" --> "*" Gate
  Gate "*" --> "1" Issuer
  Issuer --> GenTk
  GenTk --> Randomizer
  Randomizer --> GenTk
  IssuerParams --> Issuer_Tickets

  class User {
  }

  class Gate {
    <<interface>>
    - amount
    + pass(any inputs, bytes mint_inputs)
  }

  class Issuer {
    <<inferface>>
    - uint supply
    - uint balance
    - address[] gates
    - primary_splits
    + mint(address recipient)
    + update_gates(address[] gates)
    + update_splits(Split[] splits)
    + burn_supply(uint amount)
  }

  class IssuerBase {
  }

  class IssuerParams {
    + mint(address recipient, bytes inputBytes)
    + mint_ticket(address recipient)
    + exchange_ticket()
  }

  class GenTk {
    <<interface>>
    - address issuer
    - address randomizer
    - TBD code_pointer
    - Split[] royalty_splits
    - uint[] labels
    - uint state
    - uint iteration_count
    + mint(address recipient, bytes input_bytes)
    + update_details(TBD)
    + update_royalty_splits(Split[] splits)
    + setSeed(tokenId, seed)
    + reveal(tokenId, metadata)
    + mod_update_labels(uint[] labels)
    + mod_update_state(uint state, uint reason)
  }

  class Issuer_Tickets {
    - map tickets
    + transfer()
    + claim()
    + pay_tax()
  }

  class Randomizer {
    <<interface>>
    +generate(host, tokenId, minter)
  }
```

### Sequence diagrams

TODO

#### Mint

#### Mint a ticket

#### Exchange a ticket

#### ...

### Notes

- supply & balance sit on the issuer
  - the issuer is responsible for knowing if a mint can go through or not
  - the GenTk only stores the iteraion_count; it's agnostic of whether a mint can be done, if it receives a mint() request from the issuer it passes it down
- a state of a project (NONE, FLAGGED, BANNED, BLOCKED... etc) now sits in the GenTk contract
  - there is no need for a moderation contract, thus reducing the costs to mint for everyone (calling a contract replaced by getting the state)
  - note: it could also sit on the Issuer contract; TBD

## Instanciate a new project: Factory pattern

New projects are instanciated on-chain using a Factory contract, which is responsible for spawing a suite of contracts required

### Class diagram

```mermaid
classDiagram
  ProjectFactory --> Issuer_instance : instanciate
  ProjectFactory --> GenTk_instance : instanciate
  ProjectFactory --> IssuerTickets_instance : instanciate
  Issuer_instance --> GenTk_instance
  Issuer_instance ..|> Issuer_Implementation : DELEGATE_CALL
  GenTk_instance ..|> GenTk_Implementation : DELEGATE_CALL
  Issuer_instance --> IssuerTickets_instance
  IssuerTickets_instance ..|> IssuerTickets_Implementation : DELEGATE_CALL

  class ProjectFactory {
    + address issuer_implementation
    + address gentk_implementation
    + instanciate(TBD project_details, TBD gate_details)
  }

  class Issuer_Implementation {
    + mint()
    + ...()
  }

  class Issuer_instance {
    - address implementation
    - storage issuer_storage
  }

  class GenTk_Implementation {
    + mint()
    + ...()
  }

  class GenTk_instance {
    - address implementation
    - storage gentk_storage
  }

  class IssuerTickets_implementation {
    + mint()
    + pay_tax()
    + claim()
    + ...()
  }

  class IssuerTickets_instance {
    - address implementaion
    - storage issuertickets_storage
  }
```

To optimize origination costs for the artists, a proxy pattern is used for the Issuer, GenTk and IssuerTickets contracts. Some inputs are provided to the Factory to determine which kind of project should be originated, the Factory will have internal logic to spawn the necessary contracts in a proper way.

### Sequence diagrams

#### Create a new project

```mermaid
sequenceDiagram
  actor User
  participant Factory

  User->>Factory: Create project
  create participant Carl
  Factory->>Issuer: Instanciate
  create participant GenTk
  Factory->>GenTk: Instanciate
```

### Notes

- there are some circular dependencies (issuer<->gentk, gates<->issuer, etc...), how exactly can this be implemented onchain ?
- it's worth to examine whether we instanciate a new gate per project, or if we use an ID-reference in a central Gate contract, where a new entry is created instead. Need to see what's more optimized
- optimization angle:
  - the mint() entry points could be fully instanciated, to avoid having a DELEGATE_CALL to the implementation; this would shift the costs of all the mints() towards the authors of a project which would pay to store the mint() functions entirely
