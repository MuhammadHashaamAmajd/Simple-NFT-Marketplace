// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MockNFT is ERC721 {
    uint256 public currentTokenId;

    constructor() ERC721("MockNFT", "MNFT") {}

    function mint() external returns (uint256) {
        currentTokenId++;
        _mint(msg.sender, currentTokenId);
        return currentTokenId;
    }
}