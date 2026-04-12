// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MinimumPriceSales {
    struct NFT {
        uint256 id;
        address owner;
        uint256 price;
        bool forSale;
    }

    mapping(uint256 => NFT) public nfts;
    uint256 public nftCount;

    event NFTListed(uint256 id, uint256 price);
    event NFTSold(uint256 id, address buyer);

    function listNFT(uint256 _id, uint256 _price) public {
        require(nfts[_id].owner == msg.sender, "You don't own this NFT.");
        require(_price > 0, "Price must be greater than zero.");

        nfts[_id].forSale = true;
        nfts[_id].price = _price;

        emit NFTListed(_id, _price);
    }

    function buyNFT(uint256 _id) public payable {
        require(nfts[_id].forSale, "This NFT is not for sale.");
        require(msg.value >= nfts[_id].price, "Insufficient funds to buy NFT.");

        address seller = nfts[_id].owner;
        nfts[_id].owner = msg.sender;
        nfts[_id].forSale = false;

        payable(seller).transfer(msg.value);

        emit NFTSold(_id, msg.sender);
    }

    function createNFT() public {
        nftCount++;
        nfts[nftCount] = NFT(nftCount, msg.sender, 0, false);
    }
}