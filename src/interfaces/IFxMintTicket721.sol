// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct TaxInfo {
    uint128 initialPrice;
    uint128 startTime;
}

interface IFxMintTicket721 {
    error NotAuthorized();

    function burn(uint256 _tokenId) external;

    function mint(address _to, uint256 _amount) external;

    function getCurrentPrice(uint256 _tokenId) external view returns (uint256);

    function setBaseURI(string calldata _uri) external;

    function calculateExponentialDecay(
        uint256 _startingPrice,
        uint256 _timeElapsed,
        int256 _wadDecayRate
    ) external pure returns (uint256);

    function fromWad(int256 _wadValue) external pure returns (uint256);
}
