import {IDelegateCashLike} from "src/interfaces/IDelegateCashLike.sol";

contract DelegateRegistryLike is IDelegateCashLike {
    mapping(address => mapping(address => bool)) public delegates;

    function setDelegateForAll(address delegate, bool approved) public {
        delegates[msg.sender][delegate] = approved;
    }

    function checkDelegateForAll(address delegate, address vault) external view returns (bool) {
        return delegates[vault][delegate];
    }
}
