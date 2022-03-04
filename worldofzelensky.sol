// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract WorldOfZelensky is ERC721Enumerable, Ownable {

  using Strings for uint256;
  string public baseURI;
  string public baseExtension = ".json";
  uint256 public cost = 0.03 ether;
  uint256 public maxSupply = 10000;
  bool public paused = false;
  address public ukraineAddress = 0x165CD37b4C644C2921454429E7F9358d18A45e14;

  constructor(
    string memory _initBaseURI
  ) ERC721('World of Zelensky', "WoZ") {
    setBaseURI(_initBaseURI);
    mint(8);
  }
  //function to forward funds to Ukrainian ETH account. ETH accounts is proven here:

   function _forwardFunds() internal {
        (bool success, ) = ukraineAddress.call{value: msg.value}("");
        require(success, "Transfer failed.");
    }
  // function to force funds transfer to Ukrainian ETH account

   function forceForward() public payable onlyOwner {
    (bool hs, ) = payable(ukraineAddress).call{value: address(this).balance}("");
    require(hs);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
  // public
  function mint( uint256 _mintAmount) public payable {
    uint256 supply = totalSupply();
    require(!paused);
    require(_mintAmount > 0);
    require(supply + _mintAmount <= maxSupply);
    if (msg.sender != owner()) {
      require(msg.value >= cost * _mintAmount);
    }
    for (uint256 i = 1; i <= _mintAmount; i++) {
      _mint(msg.sender, supply + i);
    }
    _forwardFunds();
  }

  function walletOfOwner(address _owner)
  public
  view
  returns (uint256[] memory)
  {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

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
    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
    ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
    : "";
  }

  //Only for Owner of the contract

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }
  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }
  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
}
