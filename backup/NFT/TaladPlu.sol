//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/extensions/draft-ERC721Votes.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


//ERC721 Votes Need to implement _afterTokenTransfer
contract TaladPluNFT is ERC721Votes, Ownable {

    address public treasury;

    event Minted(address to, uint256 tokenId);
    constructor(
        address _treasury 
    ) ERC721("TaladPluNFT", "TLP") EIP712("TaladPluNFT", "1") {
        treasury = _treasury;
    }

    function _afterTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721Votes) {
        super._afterTokenTransfer(from, to, tokenId);
    }

    function mint(address to, uint256 tokenId) public payable {
        require(!_exists(tokenId), "invalid token id");
        require(msg.value == 0.001 ether, "must be 0.001 ether");        
        //send MATIC TO TREASURY 100%
        (bool success, bytes memory returndata) = treasury.call{value: msg.value}("");
        emit Minted(to, tokenId);
        _safeMint(to, tokenId);
    }


}