// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

struct TaxInfo {
    uint128 currentPrice;
    uint128 latestTime;
}

interface IFxMintTicket721 {
    event TicketInitialized(address indexed _owner, address indexed _genArt721);

    error Foreclosure();
    error NotAuthorized();
    error UnregisteredMinter();

    function burn(uint256 _tokenId) external;

    function getCurrentPrice(uint256 _tokenId) external view returns (uint256);

    function initialize(address _genArt721, address _owner) external;

    function isMinter(address _minter) external view returns (bool);

    function mint(address _to, uint256 _amount) external payable;

    function payTax(uint256 _tokenId) external payable;

    function setBaseURI(string calldata _uri) external;
}
