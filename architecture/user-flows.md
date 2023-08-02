# User flows

> This document describes the various user flows and their execution. For some particular flow, an instance of the deployed contracts will also be described.

## TODOs

- Review:
  - Publishing a project > Overview: properly specify script implementation

## Publishing a project

### Overview

Publishing a project is a 2-step process:

- publish the code
- instanciate the project Smart Contract

```mermaid
sequenceDiagram
  autonumber

  actor Author
  participant FileApi
  participant Scripty
  participant ProjectFactory

  Author->>+FileApi: submit script
  FileApi->>+FileApi: verify script
  opt script invalid
    FileApi--x-Author: error: script invalid
  end
  FileApi->>FileApi: break script into chunks
  FileApi-->>-Author: script chunks
  loop for every chunk
    Author->>Scripty: upload chunk
  end
  Author->>+Scripty: push scripts + dependencies
  Scripty-->>-Author: script pointer
  Author->>ProjectFactory: create project
```

### Instanciate the project Smart Contract

```mermaid
sequenceDiagram
  autonumber

  actor Author
  participant ProjectFactory
  participant Gates
  participant Issuer
  participant GenTk

  Author->>ProjectFactory: request instanciation (provides settings)
  opt invalid inputs
    ProjectFactory--xAuthor: error: invalid inputs
  end
  loop for every required Gate
    ProjectFactory->>Gates: instanciate gate
  end
  loop for every gate
    ProjectFactory->>Gates: link with other gates
  end
  ProjectFactory->>Issuer: instanciate
  loop for every end gate
    ProjectFactory->>Gates: link gates to issuer
  end
  ProjectFactory->>Issuer: link with end gates
  ProjectFactory->>GenTk: instanciate
  ProjectFactory->>GenTk: initialize (settings, issuer, code pointer, etc...)
  ProjectFactory->>Issuer: link GenTk
  ProjectFactory-->Author: tx injected
```

## Minting an iteration

### Free mint, full public minting

In this scenario, the issuer has a single gate, which matches its supply.

```mermaid
classDiagram
  Gate_Public --> Issuer
  Issuer --> GenTk

  class Gate_Public {
    - uint slots
    + pass(bytes calldata _calldata)
  }

  class Issuer {
    - uint supply
    + mint(address _to, bytes _inputBytes)
  }

  class GenTk {
    + mint(address _to, bytes _inputBytes)
  }
```

```mermaid
sequenceDiagram
  actor User
  participant Gate_Public
  participant Issuer
  participant GenTk
  participant Randomizer

  User->>Gate_Public: request mint
  opt if slots = 0
    Gate_Public-xUser: error: no more slots
  end
  Gate_Public->>Gate_Public: slots--
  Gate_Public->>+Issuer: [safe_mint_iteration]
  opt if supply = 0
    Issuer-xUser: error: no more supply
  end
  Issuer->>Issuer: supply--
  Issuer->>-GenTk: mint
  GenTk->>Randomizer: generate seed
  activate Randomizer
  GenTk-->User: iteration minted
  Note over Randomizer,GenTk: can be async
  Randomizer-)GenTk: set_seed
  deactivate Randomizer
```

### Paid minting, using a single pricing & no reserve

- a project simply accepts a fixed pricing
- user must pay the price to mint

```mermaid
classDiagram
  Gate_PricingFixed --> Issuer
  Issuer --> GenTk

  class Gate_PricingFixed {
    - uint opening_time
    - uint price
    - uint slots
    + pass(bytes[] _calldata)
  }

  class Issuer {
    - uint supply
    + mint(address _to, bytes _inputBytes)
  }

  class GenTk {
    + mint(address _to, bytes _inputBytes)
  }
```

```mermaid
sequenceDiagram
  actor User
  participant Gate_PricingFixed
  participant Issuer
  participant GenTk

  User->>Gate_PricingFixed: request mint
  opt if slots = 0
    Gate_PricingFixed-xUser: error: no more slots
  end
  opt if block.timestamp < opening_time
    Gate_PricingFixed-xUser: error: not opened yet
  end
  opt if not enough paid
    Gate_PricingFixed-xUser: error: not enough paid
  end
  opt if too much pay
    Gate_PricingFixed-->>User: refund difference
  end
  Gate_PricingFixed->>Gate_PricingFixed: slots--
  Gate_PricingFixed->>+Issuer: [safe_mint_iteration]
  opt if supply = 0
    Issuer-xUser: error: no more supply
  end
  Issuer->>Issuer: supply--
  Issuer->>-GenTk: mint
  GenTk-->User: iteration minted
```

### Single pricing, but 2 reserves: public & access list

```mermaid
classDiagram
  Gate_AccessList --> Gate_PricingFixed
  Gate_Public --> Gate_PricingFixed
  Gate_PricingFixed --> Issuer
  Issuer --> GenTk

  class Gate_Public {
    - uint slots
    + pass(bytes[] _calldata)
  }

  class Gate_AccessList {
    - uint slots
    - bytes32 merkleRoot
    - map tracking
    + pass(bytes[] _calldata)
  }

  class Gate_PricingFixed {
    - uint opening_time
    - uint price
    - uint slots
    + pass(bytes[] _calldata)
  }

  class Issuer {
    - uint supply
    + mint(address _to, bytes _inputBytes)
  }

  class GenTk {
    + mint(address _to, bytes _inputBytes)
  }
```

#### Minting from the public gate

> Almost same as [Free mint full public](#free-mint-full-public-minting), trivial

#### Minting from the access list

```mermaid
sequenceDiagram
  autonumber

  actor User
  participant Backend
  participant Gate_AccessList
  participant Gate_PricingFixed
  participant Issuer
  participant GenTk

  activate User
  User->>Backend: request access list details
  Backend-->>User: access list details
  User->>User: craft merkle proof
  User->>Gate_AccessList: request mint, inputs: [bytes accessList, bytes 0, bytes safe_mint_iteration]
  deactivate User
  activate Gate_AccessList
  opt if slots = 0
    Gate_AccessList-xUser: error: no more slots
  end
  opt if merkle invalid
    Gate_PricingFixed-xUser: error: invalid access list proof
  end
  opt if consumed all their slot already
    Gate_AccessList-xUser: error: not more slots for you
  end
  Gate_AccessList->>Gate_AccessList: record user mint
  Gate_AccessList->>Gate_PricingFixed: pass: [bytes 0, bytes safe_mint_iteration]
  deactivate Gate_AccessList
  activate Gate_PricingFixed
  opt if slots = 0
    Gate_PricingFixed-xUser: error: no more slots
  end
  opt if block.timestamp < opening_time
    Gate_PricingFixed-xUser: error: not opened yet
  end
  opt if not enough paid
    Gate_PricingFixed-xUser: error: not enough paid
  end
  opt if too much pay
    Gate_PricingFixed-->>User: refund difference
  end
  Gate_PricingFixed->>Gate_PricingFixed: slots--
  Gate_PricingFixed->>+Issuer: [safe_mint_iteration]
  deactivate Gate_PricingFixed
  opt if supply = 0
    Issuer-xUser: error: no more supply
  end
  Issuer->>Issuer: supply--
  Issuer->>-GenTk: mint
  GenTk-->User: iteration minted
```
