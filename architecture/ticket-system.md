# Rethinking the Tickets system

## Introduction

In the current implementation, Tickets are used to give time to collectors for minting their iteration even for params projects, even when sales are happening fast. This gives them the freedom to purchase a Ticket at sale time, and come back later to mint their params with peace of mind.

The current system forces a Harberger tax model on the Tickets, where:

- a public price must be set by the owners
- tickets can be claimed at any time at their public price
- a daily tax has to be paid, proportional to its public price
  - failure to pay such tax will result in the ticket entering remediation: a 24h dutch auction starting at the public price and linearly decreasing to a resting price of 0.1$ ~
- a grace period, defined by the artist, specifies a duration after minting where
  - owners don't have to pay any tax
  - the tickets cannot be claimed
- assets can be transfered by their owners, but cannot be put on marketplaces: the marketplace is embedded in the ticket system

The current system exhibits the following problems:

- during the grace period, tickets cannot be exchanged on the marketplace
- the logic of the tickets is heavily tied to the issuer contract. The issuer contract must implement some custom logic to process tickets, as opposed to being a more silent processors for mint requests

## Overview of various system components related to tickets

When an Issuer supports tickets, it supports 3 inputs under the hood:

| Operation        | Decrease supply | Mint iteration | Mint ticket |
| ---------------- | :-------------: | :------------: | :---------: |
| mint iteration   |        x        |       x        |      -      |
| mint ticket      |        x        |       -        |      x      |
| mint with ticket |        -        |       x        |      -      |

### Atomic operations on the issuer

A potential path to explore for improving the ticket system is to change the behaviour of the issuer to support atomic operations as opposed to bigger operations:

- `decrement supply`: decrements the supply by 1, throws if not possible
- `mint iteration`: mint an iteration of the GenTk
- `safe mint iteration`: mints an iteration on the GenTK (calls `decrement supply`)
- `mint ticket`: mints a ticket (calls `decrement supply`)
- `burn ticket`: burns a token in the associated tickets contract
- `mint with ticket`: mints an itertion with a ticket (calls `burn ticket` & `mint iteration`)

**!Danger!** The `mint iteration` atomic operation does not decrement the supply, so if manipulated improperly it can mint iterations out of the constraints of the issuer. That's why the `safe mint iteration` atomic operation is also proposed

With this new paradigm, we can maybe unlock possible behaviors by having Gates controlling the issuer with finer details. For instance, we can start thinking of a Gate_Tickets which holds the tickets being minted, and mint tickets. Which would offset the Ticketing logic outside of the issuer.

### A new reseve type: IERC5679Ext721_Burner

While not part of the ticket system, and while it may never be the case, it should be noted that the ticket system is implementing some kind of IERC5679Ext721 burner mechanism. As we'll most likely need to have such a Gate implemented at some point as well, let's describe it.

```mermaid
classDiagram
  Reserve <|-- Reserve_IERC5679Ext721_Burner : implements
  Reserve_IERC5679Ext721_Burner --> IERC5679Ext721
  Reserve_IERC5679Ext721_Burner --> Issuer

  class Reserve {
    <<interface>>
    - uint amount
    - address issuer
    + pass()
  }

  class Reserve_IERC5679Ext721_Burner {
    - address tokens
    + pass(address _from, uint256 _tokenId, bytes _data)
  }

  class IERC5679Ext721 {
    <<interface>>
    + burn(address _from, uint256 _id, bytes _data)
  }

  class Issuer {
  }
```

This is the sequence diagram of a mint when going through a Reserve_IERC5679Ext721_Burner Gate:

```mermaid
sequenceDiagram
  actor User
  participant Reserve_IERC5679Ext721_Burner
  participant IERC5679Ext721_instance
  participant Issuer

  User->>Reserve_IERC5679Ext721_Burner: pass by providing a _tokenId owned
  Reserve_IERC5679Ext721_Burner->>IERC5679Ext721_instance: burn _tokenId
  opt _tokenId cannot be burnt
    IERC5679Ext721_instance-xUser: error message
  end
  Reserve_IERC5679Ext721_Burner->>Issuer: mint
```

## 1. Tickets as any contract implementing IERC5679Ext721

We propose a mechanism where the tickets are handled by any contract implementing IERC5679Ext721. This is a naïve approach, pretty close to the current implementation. However, it still provides the ability to have custom Ticket contracts, which may be required by some organizations. Our base use-case would instanciate a new IERC5679Ext721 ticket contract if a ticket system is required for the project.

_Note: this system doesn't leverage atomic operations on the issuer_

```mermaid
classDiagram
  IERC5679Ext721 <|-- Issuer_Tickets : implements
  Gates-->Issuer_WithTickets
  Issuer_WithTickets-->Issuer_Tickets

  class Gates {

  }

  class Issuer_WithTickets {
    - address[] gates
    - address tickets
    + mint(address recipient, bytes input_bytes, boolean ticket)
    + mint_with_ticket(uint ticketId, address recipient)
  }

  class IERC5679Ext721 {
    <<interface>>
    + safeMint(address _to, uint256 _id, bytes calldata _data)
    + burn(address _from, uint256 _id, bytes calldata _data)
  }

  class Issuer_Tickets {
    <<interface>>
    - address issuer
    + safeMint() (onlyIssuer)
    + burn() (onlyIssuer)
  }
```

### Flows

#### Mint iteration

```mermaid
sequenceDiagram
  actor User
  participant Gates
  participant Issuer_WithTickets
  participant Issuer_Tickets
  participant GenTk

  User->>Gates: pass, mint_ticket = false
  Gates->>Issuer_WithTickets: mint, ticket = false
  Issuer_WithTickets->>Issuer_WithTickets: supply--
  Issuer_WithTickets->>GenTk: mint
```

#### Mint ticket

```mermaid
sequenceDiagram
  actor User
  participant Gates
  participant Issuer_WithTickets
  participant Issuer_Tickets
  participant GenTk

  User->>Gates: pass, mint_ticket = true
  Gates->>Issuer_WithTickets: mint, ticket = true
  Issuer_WithTickets->>Issuer_WithTickets: supply--
  Issuer_WithTickets->>Issuer_Tickets: mint
```

#### Mint with ticket

```mermaid
sequenceDiagram
  actor User
  participant Gates
  participant Issuer_WithTickets
  participant Issuer_Tickets
  participant GenTk

  User->>Issuer_WithTickets: mint_with_ticket, _tokenId
  Issuer_WithTickets->>Issuer_Tickets: burn _tokenId
  opt if can't burn
    Issuer_Tickets-xUser: failure
  end
  Issuer_WithTickets->>GenTk: mint
```

### Notes

- **Pros**
  - proper answer to the specs
- **Cons**
  - the issuer has to implement some logic to support tickets

## 2. Gates as Ticket manager

We propose a system where instead of having the implementation of the tickets logic inside the Issuer, we leverage the atomic operations of the issuer from a Gate which implements the ticket system. It should be noted that as once a ticket is minted, there must be a mechanic ensuring that a Gate holding tickets will always be able to exchange its tickets for an iteration.

```mermaid
classDiagram
  ERC721 <|-- Gate_Tickets : implements
  IERC5679Ext721_Harberger <|-- Gate_Tickets : implements
  Reserve <|-- Gate_Tickets : extends
  Gate_Ticket --> Issuer

  class Reserve {
    <<interface>>
    - uint amount
    - address issuer
    + pass()
  }

  class ERC721 {
    <<interface>>
  }

  class IERC5679Ext721_Harberger {
    <<interface>>
    + ...()
  }

  class Gate_Tickets {
    + pass(bytes _calldata)
    + pass_with_ticket(address _from, uint256 _ticketId, bytes _calldata)
    + mint_ticket(address _to)
  }

  class Issuer {
  }
```

With this design, the Gate_Tickets is responsible for implementing the atomic operations to interact with the issuer ([see atomic operations on the issuer](#atomic-operations-on-the-issuer))

### Sequence diagrams

#### Mint iteration

```mermaid
sequenceDiagram
  actor User
  participant Gate_Tickets
  participant Issuer
  participant GenTk

  User->>Gate_Tickets : pass()
  Gate_Tickets->>Gate_Tickets : amount--
  Gate_Tickets->>Gate_Tickets : pass reserve/pricing requirements ?
  Gate_Tickets->>Issuer : [decrease supply, safe_mint_iteration]
  opt supply = 0
    Issuer-xUser : error
  end
  Issuer->>Issuer: supply--
  Isuer->>GenTk: mint
```

#### Mint ticket

```mermaid
sequenceDiagram
  actor User
  participant Gate_Tickets
  participant Issuer

  User->>Gate_Tickets : mint_ticket()
  Gate_Tickets->>Gate_Tickets : amount--
  Gate_Tickets->>Gate_Tickets : pass reserve/pricing requirements ?
  Gate_Tickets->>Issuer : [decrease supply]
  opt supply = 0
    Issuer-xUser : error
  end
  Issuer->>Issuer: supply--
  Gate_Tickets->>Gate_Tickets : new ticket
```

#### Mint with ticket

```mermaid
sequenceDiagram
  actor User
  participant Gate_Tickets
  participant Issuer
  participant GenTk

  User->>Gate_Tickets : pass_with_ticket(_ticketId)
  opt ! ticket exists, owned by caller ?
    Gate_Tickets-xUser: error
  end
  Gate_Tickets->>Issuer : [mint iteration]
  Issuer->>GenTk : mint
```

### Notes

- **Pros**
  - Separation of concerns at the issuer level: issuer becomes simpler
  - Atomic operations on the issuer is _elegant_: it allows for more granular strategies to be implemented
- **Cons**
  - A new gate is added, which adds up a 3rd dimension for the matrix of gates (DutchAuction_PricingFixed_Tickets, DutchAuction_PricingFixed, etc...)
    - rethink packing all the gates into single contracts
    - OR have just the ticket gates be separated (but doesn't work with permanent_gates on the issuer)
  - There is too much logic implemented at the Gate_Issuer level (reserves, pricing, tickets, etc...), so effectively it's shifting complexity from the indexer to way more completxity on many different contracts
    - prone to error

### 3. Gate_Ticket, Ticket_IERC5679Ext721_Harberger

### 4. Gate_Ticket, Ticket_IERC5679Ext721_Harberger, Gate_IERC5679Ext721_Burner

---

# Notes TODO

A ticket is actually just a Gate mechanism, which we can call to have a different entry point where

Potential solutions:

- some gates just decrease the supply
- some gates decrease supply & mint NFTs
- some gates just mint NFTs

Problem:

- ticket as gates could be replaced by another Gate
  - solution: have gates & permanent_gates on the Issuer: some gates cannot be removed
- ticket as gates bring a 2rd dimension to the Gates: we now have to add support to tickets to ALL the potential Gates
- the basic use-case now becomes

The Gate ticket can actually be decomposed into 2 parts:

- generating the NFTs for the tickets
- exchanging a ticket to mint an iteration
