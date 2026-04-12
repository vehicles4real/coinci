// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";

contract MinimumPriceSales is Ownable {
    using Address for address payable;

    uint256 public constant MIN_PRICE = 1 ether;
    
    struct Listing {
        uint256 price;
        address payable seller;
        bool active;
    }

    mapping(address => mapping(uint256 => Listing)) public listings;
    mapping(address => uint256) public artistEarnings;
    mapping(address => uint256) public platformEarnings;

    event NFTListed(address indexed nftAddress, uint256 indexed tokenId, uint256 price, address indexed seller);
    event NFTPurchased(address indexed nftAddress, uint256 indexed tokenId, address indexed buyer, uint256 price);
    event PayoutDistributed(address indexed artist, uint256 artistShare, uint256 platformShare);
    event EarningsWithdrawn(address indexed recipient, uint256 amount);

    constructor() {
    }

    // List an NFT for sale with minimum 1 ETH
    function listAsset(address nftAddress, uint256 tokenId, uint256 price) public {
        require(price >= MIN_PRICE, "Price must be 1 ETH or higher");
        
        // Transfer NFT to contract
        IERC721(nftAddress).transferFrom(msg.sender, address(this), tokenId);
        
        listings[nftAddress][tokenId] = Listing(price, payable(msg.sender), true);
        emit NFTListed(nftAddress, tokenId, price, msg.sender);
    }

    // Purchase an NFT and distribute funds (75% artist, 25% platform)
    function purchaseNFT(address nftAddress, uint256 tokenId) public payable {
        Listing storage listing = listings[nftAddress][tokenId];
        
        require(listing.active, "NFT is not for sale");
        require(msg.value >= listing.price, "Insufficient payment");
        
        address payable artist = listing.seller;
        uint256 salePrice = listing.price;
        
        // Calculate splits: 75% to artist, 25% to platform
        uint256 artistShare = (salePrice * 75) / 100;
        uint256 platformShare = salePrice - artistShare;
        
        // Record earnings
        artistEarnings[artist] += artistShare;
        platformEarnings[owner()] += platformShare;
        
        // Mark listing as inactive
        listing.active = false;
        
        // Transfer NFT to buyer
        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
        
        // Refund excess payment
        if (msg.value > salePrice) {
            payable(msg.sender).sendValue(msg.value - salePrice);
        }
        
        emit NFTPurchased(nftAddress, tokenId, msg.sender, salePrice);
        emit PayoutDistributed(artist, artistShare, platformShare);
    }

    // Artists withdraw their earnings
    function withdrawArtistEarnings() public {
        uint256 amount = artistEarnings[msg.sender];
        require(amount > 0, "No earnings to withdraw");
        
        artistEarnings[msg.sender] = 0;
        payable(msg.sender).sendValue(amount);
        
        emit EarningsWithdrawn(msg.sender, amount);
    }

    // Platform owner withdraws earnings
    function withdrawPlatformEarnings() public onlyOwner {
        uint256 amount = platformEarnings[owner()];
        require(amount > 0, "No earnings to withdraw");
        
        platformEarnings[owner()] = 0;
        payable(owner()).sendValue(amount);
        
        emit EarningsWithdrawn(owner(), amount);
    }

    // Cancel listing and return NFT to seller
    function cancelListing(address nftAddress, uint256 tokenId) public {
        Listing storage listing = listings[nftAddress][tokenId];
        require(listing.seller == msg.sender, "Only seller can cancel");
        require(listing.active, "Listing is not active");
        
        listing.active = false;
        IERC721(nftAddress).transferFrom(address(this), msg.sender, tokenId);
    }

    // Check artist earnings
    function getArtistEarnings(address artist) public view returns (uint256) {
        return artistEarnings[artist];
    }

    // Check platform earnings
    function getPlatformEarnings() public view returns (uint256) {
        return platformEarnings[owner()];
    }

    // Fallback function to receive ETH
    receive() external payable {}
}