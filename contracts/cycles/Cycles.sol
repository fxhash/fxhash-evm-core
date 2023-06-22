// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/SignedMath.sol";
import "contracts/abstract/admin/FxHashAdminVerify.sol";

contract FxHashCycles is FxHashAdminVerify {
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
        _setupRole(FXHASH_ADMIN, _msgSender());
    }

    function addCycle(CycleParams calldata _params) external onlyFxHashAdmin {
        require(_params.start >= 0, "Error: start <= 0");
        require(_params.openingDuration >= 0, "Error: openingDuration <= 0");
        require(_params.closingDuration >= 0, "Error: closingDuration <= 0");
        require(
            _params.closingDuration > _params.openingDuration,
            "Error: closingDuration < openingDuration"
        );
        cycles[cyclesCount] = _params;
        cyclesCount++;
    }

    function removeCycle(uint256 _cycleId) external onlyFxHashAdmin {
        delete cycles[_cycleId];
    }

    function isCycleOpen(
        uint256 _id,
        uint256 _timestamp
    ) private view returns (bool) {
        CycleParams memory _cycle = cycles[_id];
        uint256 diff = SignedMath.abs(
            int256(int256(_timestamp) - int256(_cycle.start))
        );
        uint256 cycle_relative = SafeMath.mod(
            diff,
            _cycle.openingDuration + _cycle.closingDuration
        );
        return cycle_relative < _cycle.openingDuration;
    }

    function areCyclesOpen(
        uint256[][] calldata _ids,
        uint256 _timestamp
    ) external view returns (bool) {
        bool open = false;
        bool allOpen = false;
        for (uint256 i = 0; i < _ids.length; i++) {
            allOpen = true;
            for (uint256 j = 0; j < _ids[i].length; j++) {
                allOpen = allOpen && isCycleOpen(_ids[i][j], _timestamp);
            }
            open = open || allOpen;
        }
        return open;
    }
}
