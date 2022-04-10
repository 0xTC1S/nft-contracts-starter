// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/common/ERC2981.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
    This contract will not make use of baseURI as it will set the token uri on mint
 */

contract ERC721URIRoyalty is ERC721URIStorage, ERC2981, Ownable {
    // counter to keep knowledge of how many tokens are in circulation;
    using Counters for Counters.Counter;

    Counters.Counter public tokenId_;
    uint96 royaltyFee_;
    string contractURI_;
    address artist_;

    constructor(
        string memory _name,
        string memory _symbol,
        uint96 _fee,
        string memory _contractURI
    ) ERC721(_name, _symbol) {
        /**
            initialize state
         */
        artist_ = msg.sender;
        contractURI_ = _contractURI;

        // default royalty fee to be payed out to artist is transfers
        _setDefaultRoyalty(msg.sender, _fee);
    }

    /**
        Set up contact metadata - getter and setter
     */

    function contractURI() public view returns (string memory) {
        return contractURI_;
    }

    function setContractURI(string memory _contractURI) public onlyOwner {
        contractURI_ = _contractURI;
    }

    /**
        mintTo - used to mint the nft using metadata supplied by the artist
     */

    function mintTo(address _to, string memory _tokenURI) public {
        uint256 tokenId = tokenId_.current();
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }

    /**
        Same as above but the token royalty is also set at mint
     */
    function mintToAdjustRoyalty(
        address _to,
        string memory _tokenURI,
        uint96 _fee
    ) public onlyOwner {
        uint256 tokenId = tokenId_.current();
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        _setTokenRoyalty(tokenId, artist_, _fee);
    }

    /**
        change the metadata for a specific token
     */
    function updateTokenURI(uint256 _tokenId, string memory _tokenURI)
        public
        onlyOwner
    {
        _setTokenURI(_tokenId, _tokenURI);
    }

    /**
        update default royalty
     */
    function updateDefaultRoyalty(uint96 _fee) public onlyOwner {
        _setDefaultRoyalty(artist_, _fee);
    }

    /**
        Below are taken from ERC721 Royalty to meet the ERC2981 requirements
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
     * @dev See {ERC721-_burn}. This override additionally clears the royalty information for the token.
     */
    function _burn(uint256 tokenId) internal virtual override {
        super._burn(tokenId);
        _resetTokenRoyalty(tokenId);
    }
}
