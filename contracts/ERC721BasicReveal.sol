// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC721BasicReveal is ERC721, Ownable {
    //counter for token id
    using Counters for Counters.Counter;

    // hidden counter so that the current tokenId is hidden
    Counters.Counter private tokenId_;

    // used for string manipulation
    using Strings for uint256;

    bool revealed = false;
    string baseURI_;
    string defaultMetadataURI_;

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _uri,
        string memory _defaultMetadataURI
    ) ERC721(_name, _symbol) {
        baseURI_ = _uri;
        defaultMetadataURI_ = _defaultMetadataURI;
    }

    // sets up the baseURI for all the tokens (metadata) that are minted using this contract
    function _baseURI() internal view override returns (string memory) {
        return baseURI_;
    }

    // override the base tokeURI function - this is the function read by marketplaces that fetches the metadata for a specific token
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        // check if the tokens have been revealed yet
        if (revealed == false) {
            return defaultMetadataURI_;
        }

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    // simple mint function
    function mintTo(address _to) public {
        uint256 currentTokenId = tokenId_.current();
        _safeMint(_to, currentTokenId);
        tokenId_.increment();
    }

    // function called to reveal all the tokens
    function revealTokens() public onlyOwner returns (bool) {
        revealed = true;
        return revealed;
    }
}
