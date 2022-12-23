// SPDX-License-Identifier: MIT 
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}


// File @openzeppelin/contracts/token/ERC721/IERC721.sol@v4.7.3
 
// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;

/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}


// File @openzeppelin/contracts/utils/Context.sol@v4.7.3
 
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.7.3
 
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/utils/Strings.sol@v4.7.3
 
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";
    uint8 private constant _ADDRESS_LENGTH = 20;

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }

    /**
     * @dev Converts an `address` with fixed length of 20 bytes to its not checksummed ASCII `string` hexadecimal representation.
     */
    function toHexString(address addr) internal pure returns (string memory) {
        return toHexString(uint256(uint160(addr)), _ADDRESS_LENGTH);
    }
}


// File @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol@v4.7.3
 
// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}


// File raws/AuctionHouse.sol/
pragma solidity ^0.8.9;




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
