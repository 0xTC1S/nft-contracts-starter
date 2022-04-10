const ERC721URIRoyalty = artifacts.require("ERC721URIRoyalty");

module.exports = function (deployer) {
  deployer.deploy(
    ERC721URIRoyalty,
    "Test",
    "test",
    250,
    "ipfs://QmdYABdjNDc5NUjjLcQrD5ij5suFybM7qSiYqvB4gaobx3"
  );
};
