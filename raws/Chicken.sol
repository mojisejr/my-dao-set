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

    uint256 private currentTokenId = 0;

    struct TokenInfo {
        string baseURI;
        bool completed;
    } 

    mapping(uint256 => TokenInfo) private tokens;

    constructor(address _admin, address _auction) ERC721("ChickenDAONFT", "CIK") EIP712("ChickenDAONFT", "1") {
         _setupRole(ADMIN_ROLE, _admin);
         _setupRole(MINTER_ROLE, _auction);
         _setupRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    // EVENTS
    /////////

    event Minted(address indexed minter, uint256 tokenId);
    event SetBaseUri(uint256 tokenId, string baseUri);

    // Internal Functions
    /////////////////////

    function _increseTokenId() internal {
        currentTokenId += 1;
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

     function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId);
    }



    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable, ERC2981, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Public View Functions
    ///////////////////////

    function getCurrentTokenId() public view returns(uint256) {
        return currentTokenId + 1;
    }

    function isCompleted(uint256 _tokenId) public view returns(bool) {
        return tokens[_tokenId].completed;

    }

    function tokenURI(uint256 _tokenId) public view override returns(string memory) {
        if(tokens[_tokenId].completed) {
            return tokens[_tokenId].baseURI;
        } else {
            return "ipfs:://";
        }
    }


    // Minting Functions
    ////////////////////

    function mint() public payable onlyRole(MINTER_ROLE) {
        uint256 tokenId = getCurrentTokenId();
        emit Minted(msg.sender, tokenId);
        _safeMint(msg.sender, tokenId);
        _increseTokenId();
    }

    function burn(uint256 _tokenId) override public onlyRole(MINTER_ROLE) {
        _burn(_tokenId);
    }

    // Base URI setting functions
    /////////////////////////////

    function setBaseUri(uint256 _tokenId, string memory _baseUri) public onlyRole(MINTER_ROLE) {
        require(!tokens[_tokenId].completed, 'uri has already set');
        tokens[_tokenId].completed = true;
        tokens[_tokenId].baseURI = _baseUri;

        emit SetBaseUri(_tokenId, _baseUri);
    }

    
    //ERC2981 Royalty
    /////////////////

    function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyRole(ADMIN_ROLE) {
        _setDefaultRoyalty(receiver, feeNumerator);
    }

    function deleteDefaultRoyalty() public onlyRole(ADMIN_ROLE) {
        _deleteDefaultRoyalty();
    }

    function setTokenRoyalty(uint256 tokenId, address receiver, uint96 feeNumerator) public onlyRole(ADMIN_ROLE) {
        _setTokenRoyalty(tokenId, receiver, feeNumerator);
    }

    function resetTokenRoyalty(uint256 tokenId) public onlyRole(ADMIN_ROLE) {
        _resetTokenRoyalty(tokenId);
    }
}