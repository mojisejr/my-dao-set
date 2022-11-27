//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

contract ChickenDAONFT is ERC721, ERC721Enumerable, AccessControl, ERC721Votes, ERC721Burnable, ERC2981, ReentrancyGuard {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 currentTokenId = 0;

    mapping(uint256 => string) private baseURI;
    mapping(uint256 => bool) private completed;

    constructor(address _admin, address _auction) ERC721("ChickenDAONFT", "CIK") EIP712("ChickenDAONFT", "1") {
         _setupRole(ADMIN_ROLE, _admin);
         _setupRole(MINTER_ROLE, _auction);
         _grantRole(DEFAULT_ADMIN_ROLE, _admin);
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

    function getCurrentTokenId() public view returns(uint256) {
        return currentTokenId + 1;
    }

    function isCompleted(uint256 _tokenId) public view returns(bool) {
        return completed[_tokenId];
    }

    function mint() public payable onlyRole(MINTER_ROLE) {
        uint256 tokenId = getCurrentTokenId();
        emit Minted(msg.sender, tokenId);
        _safeMint(msg.sender, tokenId);
        _increseTokenId();
    }

    function setBaseUri(uint256 _tokenId, string memory _baseUri) public onlyRole(ADMIN_ROLE) {
        require(!completed[_tokenId], 'uri has already set');
        completed[_tokenId] = true;
        baseURI[_tokenId] = _baseUri;

        emit SetBaseUri(_tokenId, _baseUri);
    }

    
    function tokenURI(uint256 _tokenId) public view override returns(string memory) {
        require(completed[_tokenId], 'token does not existed!');
        return baseURI[_tokenId];      
    }


    //ERC2981

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function deleteDefaultRoyalty() public onlyOwner {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) public onlyOwner {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    function resetTokenRoyalty(uint256 tokenId) public onlyOwner {
        _resetTokenRoyalty(tokenId);
    }



    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

}