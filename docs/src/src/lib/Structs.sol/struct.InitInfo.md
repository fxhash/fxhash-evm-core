# InitInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/686a75b6e028ec629d05b5b60596a8ee209b77b5/src/lib/Structs.sol)

Struct of initialization information used on project creation
- `name` Name of project
- `symbol` Symbol of project
- `primaryReceiver` Address of splitter contract receiving primary sales
- `randomizer` Address of Randomizer contract
- `renderer` Address of Renderer contract
- `tagIds` Array of tag IDs describing the project


```solidity
struct InitInfo {
    string name;
    string symbol;
    address primaryReceiver;
    address randomizer;
    address renderer;
    uint256[] tagIds;
}
```

