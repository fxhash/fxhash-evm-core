# InitInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/941c33e8dcf9e8d32ef010e754110434710b4bd3/src/lib/Structs.sol)

Struct of initialization information used on project creation
- `name` Name of project
- `symbol` Symbol of project
- `primaryReceiver` Address of splitter contract receiving primary sales
- `randomizer` Address of Randomizer contract
- `renderer` Address of Renderer contract
- `tagIds` Array of tag IDs describing the project
- 'onchainData' Onchain data to be stored using SSTORE2 and available to renderers


```solidity
struct InitInfo {
    string name;
    string symbol;
    address[] primaryReceivers;
    uint32[] allocations;
    address randomizer;
    address renderer;
    uint256[] tagIds;
    bytes onchainData;
}
```

