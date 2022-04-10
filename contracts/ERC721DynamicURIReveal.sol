// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721DynamicURIReveal is ERC721, Ownable {
    // counter for token id
    using Counters for Counters.Counter;

    // hidden counter so that the current tokenId is hidden
    Counters.Counter private tokenId_;

    // used for string manipulation
    using Strings for uint256;

    // base uri
    string baseURI_;

    // defualt metadata uri for before the reveal has taken place
    string defaultMetadataURI_;

    // reveal time in seconds
    uint256 revealTime_;

    // mapping between tokenid and uri
    mapping(uint256 => string) private _tokenURIs;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _defaultMetadataURI,
        uint256 _revealTime
    ) ERC721(_name, _symbol) {
        defaultMetadataURI_ = _defaultMetadataURI;
        revealTime_ = _revealTime;
    }

    // update the reveal date
    function changeReveal(uint256 _revealTime) public returns (uint256) {
        revealTime_ = _revealTime;
        return revealTime_;
    }

    /**
        modified version of ERC721URIStorage tokenURI
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // show default data if not revealed
        if (block.timestamp < revealTime_) {
            return defaultMetadataURI_;
        }

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }

    /**
        Taken from ERC721URIStorage
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI)
        internal
        virtual
    {
        require(_exists(tokenId), "URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
        Taken from ERC721URIStorage
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);

        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
