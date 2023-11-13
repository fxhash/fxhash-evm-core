# InitInfo
[Git Source](https://github.com/fxhash/fxhash-evm-contracts/blob/709c3bd5035ed7a7acc4391ca2a42cf2ad71efed/src/lib/Structs.sol)

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

