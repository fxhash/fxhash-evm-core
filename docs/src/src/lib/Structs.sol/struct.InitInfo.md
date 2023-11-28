# InitInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/437282be235abab247d75ca27e240f794022a9e1/src/lib/Structs.sol)

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
    address[] primaryReceivers;
    uint32[] allocations;
    address randomizer;
    address renderer;
    uint256[] tagIds;
}
```

