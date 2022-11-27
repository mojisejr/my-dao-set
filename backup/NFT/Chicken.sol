//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";

contract DrawDAONFT is ERC721, ERC721Enumerable, AccessControl, ERC721Votes {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    uint256 currentTokenId = 0;
    uint256 amountPerDay = 5;
    uint256 startTime;
    uint256 releasePeriod = 300;
    uint256 public currentMintedAmountPerDay = 0;
    uint256 price = 0.001 ether;
    address treasury;
    address dev;

    mapping(uint256 => string) private baseURI;
    mapping(uint256 => bool) private completed;

    constructor(address _admin, address _treasury, address _dev) ERC721("DrawDAONFT", "DDT") EIP712("DrawDAONFT", "1") {
         _setupRole(ADMIN_ROLE, _admin);
         _grantRole(DEFAULT_ADMIN_ROLE, _admin);
         treasury = _treasury;
         dev = _dev;
         startTime = block.timestamp;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

     function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId);
    }

    event Minted(address indexed minter, uint256 tokenId);
    event SetBaseUri(uint256 tokenId, string baseUri);

    function _increseTokenId() internal {
        currentTokenId += 1;
    }

    function _increaseAmountPerDay() internal {
        currentMintedAmountPerDay += 1;
    }

    function _resetAmountPerDay() internal {
        currentMintedAmountPerDay = 0;
    }

    function _setNewNextMint() internal {
        startTime = block.timestamp + releasePeriod;
    }

    function getCurrentTokenId() public view returns(uint256) {
        return currentTokenId + 1;
    }

    function getStartTime() public view returns(uint256) {
        return startTime;
    }

    function isCompleted(uint256 _tokenId) public view returns(bool) {
        return completed[_tokenId];
    }

    function mint() public payable {
        require(block.timestamp > startTime, 'not open yet!');
        require(msg.value >= price, 'invalid price');
        uint256 tokenId = getCurrentTokenId();
        emit Minted(msg.sender, tokenId);
        _safeMint(msg.sender, tokenId);

        uint256 half = msg.value / 2;

        (bool success, bytes memory returndata) = treasury.call{value: half}("");
        (bool success1, bytes memory returndata1) = dev.call{value: half}("");

        if(currentMintedAmountPerDay < amountPerDay - 1) {
            _increaseAmountPerDay();
        } else {
            _setNewNextMint();
            _resetAmountPerDay();
        }

        _increseTokenId();
    }

    function setBaseUri(uint256 _tokenId, string memory _baseUri) public onlyRole(ADMIN_ROLE) {
        require(!completed[_tokenId], 'uri has already set');
        completed[_tokenId] = true;
        baseURI[_tokenId] = _baseUri;

        emit SetBaseUri(_tokenId, _baseUri);
    }
    
    function setAmountPerDay(uint256 _newAmount) public onlyRole(ADMIN_ROLE) {
        require(_newAmount > 0, 'invalid amount');
        amountPerDay = _newAmount;
    }

    function setReleasePeriod(uint256 _newPeriod) public onlyRole(ADMIN_ROLE) {
        require(_newPeriod > 300, 'invalid period');
        releasePeriod = _newPeriod;
    }

    function setPrice(uint256 _newPrice) public onlyRole(ADMIN_ROLE) {
        require(_newPrice > 0, 'invalid price');
        price = _newPrice;
    }
    
    function tokenURI(uint256 _tokenId) public view override returns(string memory) {
        require(completed[_tokenId], 'token does not existed!');
        return baseURI[_tokenId];      
    }


    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}