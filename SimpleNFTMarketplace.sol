// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract SimpleNFTMarketplace {
    struct Listing {
        address seller;
        uint256 price;
        uint256 expiration;
    }

    // nft contract address => token ID => Listing
    mapping(address => mapping(uint256 => Listing)) public listings;

    event Listed(address indexed seller, address indexed nftContract, uint256 indexed tokenId, uint256 price, uint256 expiration);
    event Bought(address indexed buyer, address indexed nftContract, uint256 indexed tokenId, uint256 price);
    event Canceled(address indexed seller, address indexed nftContract, uint256 indexed tokenId);

    function sell(address _nftContract, uint256 _tokenId, uint256 _price, uint256 _durationInSeconds) external {
        require(_price > 0, "price must be greater than zero");
        require(listings[_nftContract][_tokenId].price == 0, "nft already listed dude");

        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "you dont own this nft");
        require(nft.getApproved(_tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "marketplace not approved");

        uint256 expireTime = block.timestamp + _durationInSeconds;

        listings[_nftContract][_tokenId] = Listing({
            seller: msg.sender,
            price: _price,
            expiration: expireTime
        });

        emit Listed(msg.sender, _nftContract, _tokenId, _price, expireTime);
    }

    function buy(address _nftContract, uint256 _tokenId) external payable {
        Listing memory item = listings[_nftContract][_tokenId];
        require(item.price > 0, "not listed for sale");
        require(block.timestamp <= item.expiration, "listing expired");
        require(msg.value == item.price, "incorrect ether amount sent");

        delete listings[_nftContract][_tokenId];

        IERC721(_nftContract).transferFrom(item.seller, msg.sender, _tokenId);
        payable(item.seller).transfer(msg.value);

        emit Bought(msg.sender, _nftContract, _tokenId, item.price);
    }

    function cancel(address _nftContract, uint256 _tokenId) external {
        Listing memory item = listings[_nftContract][_tokenId];
        require(item.price > 0, "not listed");
        require(item.seller == msg.sender, "not your listing");

        delete listings[_nftContract][_tokenId];

        emit Canceled(msg.sender, _nftContract, _tokenId);
    }
}