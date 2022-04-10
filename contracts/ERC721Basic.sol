// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721Basic is ERC721, Ownable {
    //counter for token id
    using Counters for Counters.Counter;

    // hidden counter so that the current tokenId is hidden
    Counters.Counter private tokenId_;

    //state variable for baseURI
    string baseURI_;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri
    ) ERC721(_name, _symbol) {
        // set the baseURI
        baseURI_ = _uri;
    }

    // sets up the baseURI for all the tokens (metadata) that are minted using this contract
    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }

    // simple mint function
    function mintTo(address _to) public {
        uint256 currentTokenId = tokenId_.current();
        _safeMint(_to, currentTokenId);
        tokenId_.increment();
    }
}
