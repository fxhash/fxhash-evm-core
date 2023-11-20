// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IToken} from "src/interfaces/IToken.sol";
import {ReserveInfo} from "src/interfaces/IFxGenArt721.sol";

contract MockMinter {
    function mint(address _token, address _to, uint256 _amount, uint256 _payment) external {
        IToken(_token).mint(_to, _amount, _payment);
    }

    function setMintDetails(ReserveInfo calldata _reserveInfo, bytes calldata _mintDetails) external {}
}
