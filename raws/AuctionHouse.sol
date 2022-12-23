//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



interface INFT is IERC721 {
    function getCurrentTokenId() external view returns(uint256);
    function totalSupply() external view returns(uint256);
    function mint() external;
    function burn(uint256 _tokenId) external;
}


contract ChickenDAOAuctionHouse is IERC721Receiver, Ownable {

    using Strings for uint256;

    event AuctionStarted(uint256 indexed bidId, uint256 tokenId, uint256 start, uint256 end, address bidder);
    event NewBid(uint256 indexed tokenId, uint256 start, uint256 end);
    event Bidded(uint256 indexed bidId, address indexed bidder,  uint256 previousBid, uint256 currentBid, uint256 tokenId);
    event Settled(uint256 indexed bidId, address indexed bidder, uint256 amount);
    event Received(uint256 indexed tokenId, address indexed owner, bytes data);

    struct Bidder {
        address bidder;
        uint amounts;
    }

    struct Bid {
        address bidder;
        uint256 amounts; 
        uint256 tokenId;
        uint256 start;
        uint256 end;
        Bidder[] bidders;
        bool ended;
    }



    //AUCTION PARAMETERS
    uint256 currentBidId = 0; 
    mapping(uint256 => Bid) public bids;

    //BKC 5 secs / block
    // uint256 public auctionPeriod = 10;
    uint256 public minimumBid = 0.2 ether;
    uint256 public auctionPeriod = 3 minutes;

    bool public started = false;
    bool public paused = true;

    //NFT 
    INFT public nft;

    //Treasury - DEV wallet
    address dev;
    address treasury;

    // Constructor
    //////////////

    constructor(address _dev, address _treasury) {
        dev = _dev;
        treasury = _treasury;
    }

    // Admin Functions
    //////////////////

    function setMinimumBid(uint256 _bidAmounts) public onlyOwner {
        require(_bidAmounts > 0, "setMinimumBit: Invalid minimum bid.");
        minimumBid = _bidAmounts;
    }

    function setDevAddress(address _dev) public onlyOwner {
        require(_dev != address(0), 'setDevAddress: invalid address');
        dev = _dev;
    }

    function setNFTAddress(INFT _nft) public onlyOwner {
        require(_nft != INFT(address(0)), 'setDevAddress: invalid address');
        nft = _nft;
    }

    function setTreasuryAddress(address _treasury) public onlyOwner {
        require(_treasury != address(0), 'setDevAddress: invalid address');
        treasury = _treasury;
    }

    function setAuctionPeriod(uint256 _period) public onlyOwner {
        auctionPeriod = _period;
    }

    function pause() public onlyOwner {
        require(bids[currentBidId].amounts <= 0, 'pause: cannot be paused due to > 0 bidding amount');
        paused = true;
    }

    function resume() public onlyOwner {
        require(paused, 'resume: Auction is started');
        paused = false;
    }

    // Public View Fuctions
    ///////////////////////

    function getCurrentBidId() public view returns(uint256) {
        return currentBidId;
    }

    function getCurrentTokenId() public view returns(uint256) {
        return nft.getCurrentTokenId() - 1;
    }

    function getCurrentTimestamp() public view returns(uint256) {
        return block.timestamp;
    }

    function getLatestBid() public view returns(Bid memory) {
        uint256 currentBidId = getCurrentBidId(); 
        return bids[currentBidId];
    }

    function getAllBids () public view returns(Bid[] memory) {
		uint256 bidLen = getCurrentBidId() + 1;
        require(bidLen > 0, "getAllBids: no auctions");
		Bid[] memory bidArray = new Bid[](bidLen);
		for(uint256 i = 0; i < bidLen; i++) {
			bidArray[i] = bids[i];
		}
		return bidArray;
	}

    function getBatchBids (uint256 from, uint256 to) public view returns(Bid[] memory) {
        uint256 size = to - from;
        require(size > 0, "getBatchBids: no auctions");
		Bid[] memory bidArray = new Bid[](size);
		for(uint256 i = from; i < to + 1; i++) {
			bidArray[i] = bids[i];
		}
		return bidArray;
    }

    function getBalance() public view returns(uint256) {
        return address(this).balance;
    }

    // Internal Functions
    /////////////////////

    function _increaseBidId() internal {
        currentBidId += 1;
    }

    function _getEndTimestamp() internal view returns(uint256) {
        return block.timestamp + auctionPeriod;
    }


    function _newBid (uint256 _bidId, address payable _bidder, uint256 _amounts, uint256 _tokenId, uint256 _end) internal {
        bids[_bidId].bidder = _bidder;
        bids[_bidId].amounts = _amounts;
        bids[_bidId].tokenId = _tokenId;
        bids[_bidId].start = block.timestamp;
        bids[_bidId].end = _end;
        bids[_bidId].ended = false;

        emit NewBid(_tokenId, block.timestamp, _end);
    }

    function _updateBid(uint256 _bidId, address payable _newBidder, uint256 _newAmounts) internal {
        bids[_bidId].bidder = _newBidder; 
        bids[_bidId].amounts = _newAmounts;
        //update history with amounts
        Bidder memory bidder = Bidder(_newBidder, _newAmounts);
        bids[_bidId].bidders.push(bidder);
    }

    function _mintToken() internal {
        nft.mint();
    }

    function _burnToken(uint256 _tokenId) internal {
        nft.burn(_tokenId);
    } 

    function _refund(address _to, uint256 _amounts) internal {
        require(bids[currentBidId].amounts > 0, "_refund: cannot refund 0 amounts");
        (bool sent, bytes memory data) = _to.call{value: _amounts}("");
        require(sent, "_refund: Refunding Failed.");
    }

    // Auction Functions (CORE)
    ///////////////////////////

    //only for start the first bid
    function start() public payable {
        require(!started, "start: Auction house already started");
        started = true;

        uint256 bidId = getCurrentBidId(); 
        _mintToken();

        uint256 tokenId = getCurrentTokenId();
        uint256 endTimestamp = _getEndTimestamp();
        _newBid(bidId, payable(address(0)), 0, tokenId, endTimestamp); 

        paused = false;

        emit AuctionStarted(bidId, tokenId, block.timestamp, endTimestamp, msg.sender);
    } 

    //bidder place their bid here
    function bid() public payable{
        require(block.timestamp < bids[currentBidId].end, 'bid: Auction is now ended.');
        require(!bids[currentBidId].ended, "bid: Auction is now ended.");
        require(bids[currentBidId].bidder != msg.sender, "bid: you are the current bidder");
        require(msg.value >= bids[currentBidId].amounts + minimumBid, "bid: invalid bidding amounts, must be higher than the highest bit + minimumBid amounts");

        uint256 previousBidAmount = bids[currentBidId].amounts;
        address previousBidder = bids[currentBidId].bidder;
        if(previousBidAmount > 0) {
            _refund(previousBidder, previousBidAmount);
        }

        _updateBid(currentBidId, payable(msg.sender), msg.value);

        emit Bidded(currentBidId, msg.sender, previousBidAmount, msg.value, bids[currentBidId].tokenId);
    } 

    //settle auction and mint new tokenId
    function settle() public payable {
        require(!paused, "settle: Auction House is now closed.");
        require(!bids[currentBidId].ended, "settle: Auction is not end yet.");
        require(block.timestamp > bids[currentBidId].end, "settle: Auction still on going.");

        //In case of Has some bid
        if(bids[currentBidId].bidder != payable(address(0)) && bids[currentBidId].amounts > 0) {
            //1. CLOSE CURRENT AUCTION
            bids[currentBidId].ended = true;

            //2. SEND NFT TO HIGHEST BIDDER
            nft.safeTransferFrom(address(this), bids[currentBidId].bidder, bids[currentBidId].tokenId);

            //3. SEND TOKEN to destination
            uint256 half = address(this).balance / 2;
            (bool toDev, bytes memory returnedData1) = dev.call{value: half}("");
            (bool toTreasury, bytes memory returnData2) = treasury.call{value: half}("");
            require(toDev, "settle: send token to dev failed.");
            require(toTreasury, "settle: send token to treasury failed.");

            //4. MINT NEW NFT
            _mintToken();
            _increaseBidId();
            uint256 nextBidId = getCurrentBidId();
            uint256 tokenId = getCurrentTokenId(); 
            uint256 nextPeriod = _getEndTimestamp();
            //5. START NEW AUCTION
            _newBid(nextBidId, payable(address(0)), 0, tokenId, nextPeriod); 

        } else if(bids[currentBidId].amounts <= 0) {
            //In case of has no bid
            //1. CLOSE CURRENT AUCTIO
            bids[currentBidId].ended = true;

            //2. SENT CURRENT NFT TO BURN 
            uint256 toBurnId = bids[currentBidId].tokenId;
            _burnToken(toBurnId);

            //4. MINT NEW NFT
            _mintToken();
            _increaseBidId();
            uint256 nextBidId = getCurrentBidId();
            uint256 tokenId = getCurrentTokenId(); 
            uint256 nextPeriod = _getEndTimestamp();
            //5. START NEW AUCTION
            _newBid(nextBidId, payable(address(0)), 0, tokenId, nextPeriod); 
        }

        emit Settled(currentBidId, bids[currentBidId].bidder, bids[currentBidId].amounts);
    }


    //HELPER FUNCTIONS
    //////////////////

    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function onERC721Received(address operator, address from,  uint256 _tokenId, bytes calldata data) external override returns(bytes4) {
        emit Received(_tokenId, from, data);
        return this.onERC721Received.selector;
    }
}
