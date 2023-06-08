// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "contracts/libs/lib-admin/LibAdmin.sol";

contract FxHashCycles is AccessControl {
    struct CycleParams {
        uint256 start;
        uint256 openingDuration;
        uint256 closingDuration;
    }

    mapping(uint256 => CycleParams) public cycles;
    uint256 private cyclesCount;

    constructor() {
        cyclesCount = 0;
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(LibAdmin.FXHASH_ADMIN, _msgSender());
    }

    modifier onlyAdmin() {
        require(AccessControl.hasRole(AccessControl.DEFAULT_ADMIN_ROLE, _msgSender()), "Caller is not an admin");
        _;
    }

    modifier onlyFxHashAdmin() {
        require(AccessControl.hasRole(LibAdmin.FXHASH_ADMIN, _msgSender()), "Caller is not a FxHash admin");
        _;
    }

    // Function to grant the ADMIN_ROLE to an address
    function grantAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }

    // Function to revoke the ADMIN_ROLE from an address
    function revokeAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(AccessControl.DEFAULT_ADMIN_ROLE, _admin);
    }

    function grantFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.grantRole(LibAdmin.FXHASH_ADMIN, _admin);
    }

    function revokeFxHashAdminRole(address _admin) public onlyAdmin {
        AccessControl.revokeRole(LibAdmin.FXHASH_ADMIN, _admin);
    }

    function addCycle(CycleParams calldata _params) external onlyFxHashAdmin{
        require(_params.start >= 0, "Error: start <= 0");
        require(_params.openingDuration >= 0, "Error: openingDuration <= 0");
        require(_params.closingDuration >= 0, "Error: closingDuration <= 0");
        require(_params.closingDuration > _params.openingDuration, "Error: closingDuration < openingDuration");
        cycles[cyclesCount] = _params;
        cyclesCount++;
    }

    function removeCycle(uint256 _cycleId) external onlyFxHashAdmin{
        delete cycles[_cycleId];
    }

    function isCycleOpen(uint256 _id, uint256 _timestamp) private view returns (bool){
        CycleParams memory _cycle = cycles[_id];
        uint256 diff = SignedMath.abs(int256(int256(_timestamp) - int256(_cycle.start)));
        uint256 cycle_relative = SafeMath.mod(diff, _cycle.openingDuration + _cycle.closingDuration);
        return cycle_relative < _cycle.openingDuration;
    }

    function areCyclesOpen(uint256[][] calldata _ids, uint256 _timestamp) external view returns (bool) {
        bool open = false;
        bool allOpen = false;
        for (uint256 i = 0; i < _ids.length; i++)
        {
            allOpen = true;
            for (uint256 j = 0; j < _ids[i].length; j++)
            {
                allOpen = allOpen && isCycleOpen(_ids[i][j], _timestamp);
            }
            open = open || allOpen;
        }
        return open;
    }
}