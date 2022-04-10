// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

// payable mint function but with the chance for the end user to set the URI and royalty fee on mint

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/PullPayment.sol";

contract ERC721URIPayableMint is ERC721, ERC2981, Ownable, PullPayment {
    // mapping between tokenid and uri
    mapping(uint256 => string) private _tokenURIs;
    // counter for token id
    using Counters for Counters.Counter;
    // used for string manipulation
    using Strings for uint256;

    // hidden counter so that the current tokenId is hidden
    Counters.Counter private tokenId_;

    uint256 public totalSupply_;
    uint256 public mintPrice_; // value in wei as msg.value is in this format

    address contractOwner;

    constructor(
        string memory _name,
        string memory _symbol,
        uint256 _mintPrice,
        uint256 _totalSupply
    ) ERC721(_name, _symbol) {
        totalSupply_ = _totalSupply;
        mintPrice_ = _mintPrice;
    }

    function setMintPrice(uint256 _mintPrice) public onlyOwner {
        mintPrice_ = _mintPrice;
    }

    /**
        mint function
     */

    function mintTo(
        address _to,
        string memory _uri,
        uint96 _fee
    ) public payable {
        uint256 currentTokenId = tokenId_.current();
        require(
            totalSupply_ < currentTokenId,
            "Can't mint any more nfts - limit reached"
        );
        // make sure the minter does not set royalty too high
        require(_fee < 1000, "Fee is too high!");
        // check if value sent to the contract is the amount required to mint
        require(
            msg.value == mintPrice_,
            "You must send the correct amount of ether to mint"
        );

        _safeMint(_to, currentTokenId);
        _setTokenRoyalty(currentTokenId, msg.sender, _fee);
        _setTokenURI(currentTokenId, _uri);

        tokenId_.increment();
    }

    /**
        withdraw function -  withdraw ether from the contract - this is where the cost of minting goes
     */

    function withdrawPayments(address payable owner)
        public
        virtual
        override
        onlyOwner
    {
        super.withdrawPayments(owner);
    }

    /**
        Taken from ERC721URIStorage
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
        Taken from ERC721Royalty
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC721, ERC2981)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
        Taken from ERC721URIStorage
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
