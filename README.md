# fxhash-case-study

# Requirements
- artists can publish their Generative Art project on the platform
    - they can upload their code to a decentralized media network
    - they can provide some details on the project, which will be stored as JSON on the decentralized media network
    - they can push their project on the Smart Contracts, with the following set of options:
        - number of editions (how many unique iterations can be minted by collectors)
        - price (the price to get one edition)
        - opening time (when can users start minting the project)
        - code: pointer to the code stored off chain
        - details: pointer to the project details stored off chain
        - list of splits: a list of addresses & a percentage, to which funds will be sent when a purchase occurs
        - royalties: a percentage, indicating how much will be sent to the splits when a sale occurs on the secondary market
- users can browse the different projects on a website
- users can mint unique iterations of the projects published to the Smart Contract
    - if:
        - they provide enough money
        - the project is not minted out
    - the mint operation should result in:
        - a NFT minted in a smart contract with widely adopted specifications, allowing for the integration of the NFTs across the ecosystem
        - a unique 32 bytes seed, which will be associated with the unique iteration
        - a NFT in a blank state, waiting to be revealed
- NFTs should be revealed with a off-chain system
    - a module should reveal NFTs after they are minted, by using the project code + unique iteration seed to generate the outputs
    - some JSON metadata, compliant with NFT specs, will be stored in the decentralized media network
    - the JSON metadata will be pushed to the NFT Smart Contract, effectively revealing it
- users can put their NFTs for sale on our platform
    - other users may accept the sales
- users can make offers on other NFTs, or project-wide offers (offer X for any piece of Y project)
    - owners can accept such offers
- users have access to market statistics
    - overall statistics such as:
        - daily platform sales (primary/secondary)
        - daily users
    - project statistics such as:
        - overall stats
            - total sales on primary, secondary
            - floor
            - median price
            - sales on the last 24h (primary, secondary)
        - charts of the floor
        - charts of the average price
        - charts of the sales


# Contracts
## Royalties
Rely on industry standard: https://github.com/manifoldxyz/royalty-registry-solidity
## Standard
ERC1155: https://docs.openzeppelin.com/contracts/3.x/erc1155
ERC2981: https://docs.openzeppelin.com/contracts/4.x/api/token/common#ERC2981
Ownable
Pausable
Upgradable
Metadata update: https://eips.ethereum.org/EIPS/eip-4906
Payment Splitter: https://docs.openzeppelin.com/contracts/4.x/api/finance#PaymentSplitter
## Attributes
- number of editions
- price
- opening time
- code
- details
- royalties
- splits

## custom entrypoints
- mint()
  - users can mint unique iterations of the projects published to the Smart Contract
      - if:
          - they provide enough money
          - the project is not minted out
      - the mint operation should result in:
          - a NFT minted in a smart contract with widely adopted specifications, allowing for the integration of the NFTs across the ecosystem
          - a unique 32 bytes seed, which will be associated with the unique iteration
          - a NFT in a blank state, waiting to be revealed
- reveal()



# Marketplace features
- browse nft
- buy
- sell
- bid
- collection bid
- users have access to market statistics
    - overall statistics such as:
        - daily platform sales (primary/secondary)
        - daily users
    - project statistics such as:
        - overall stats
            - total sales on primary, secondary
            - floor
            - median price
            - sales on the last 24h (primary, secondary)
        - charts of the floor
        - charts of the average price
        - charts of the sales


# Backend features
- NFTs should be revealed with a off-chain system
    - a module should reveal NFTs after they are minted, by using the project code + unique iteration seed to generate the outputs
    - some JSON metadata, compliant with NFT specs, will be stored in the decentralized media network
    - the JSON metadata will be pushed to the NFT Smart Contract, effectively revealing it

# indexing
https://docs.subsquid.io/quickstart/quickstart-abi/

# Going further
- explore possibilities provided by ERC3525