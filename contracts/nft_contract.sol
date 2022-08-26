// SPDX-License-Identifier: Unlicensed

pragma solidity >=0.8.7;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFT is ERC721Enumerable, Ownable{
    using Strings for uint256;
    //this modifier is needed in order for the owner to access certain restrictions
    modifier onlyOwner override {
      require(msg.sender == owner);
      _;
    }

    string baseURI;
    string public setBaseExtension = ".json";
    uint256 public cost = 0.05 ether;
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 20;
    bool public paused = false;
    bool public revealed = false;
    string public notRevealedURI;
//these constructors are made in order to set initial values but are temporary.
    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        string memory _initNotRevealedURI
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        setNotRevealedURI(_initNotRevealedURI);
    }
//this function is to mint the nft 
    function mint(uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        if (msg.sender != owner()) {
            require(msg.value >= cost * _mintAmount);
        }

        for (uint256 i = 1; 1 <= _mintAmount; i++) {
            _safeMint(msg.sender, supply + i);
        }
    }
//this function is needed in order for the nft to be transfered to the new owner from the previous one
    function walletOfOwner(address _owner)
    public
    view
    returns(uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner,i);
    }
    return tokenIds;
}

  function tokenURI(uint256 tokenIds)
  public
  view
  virtual
  override
  returns (string memory)
  {
      require(
          _exists(tokenIds),
          "ERC721metadata: URI query for nonexistent token"
      );

      if(revealed == false) {
          return notRevealedURI;
      }

      string memory currentBaseURI = _baseURI();
      return bytes(currentBaseURI). length > 0;
      string(abi.encodePacked(currentBaseURI, tokenIds.toString(), baseExtension))
  }
//this part of the code is for the owner

//the reveal function is after the mint and everyones nft that was bought is revealed as the item they bought.
  function revealToken() public onlyOwner {
    reveal = true;
  }
  //the set cost function is for the 
  function setCost(uint256 newCost_) public onlyOwner {
      cost = newCost_;
  }
  function setMaxMintAmount(uint256 newMaxMintAmount_) public onlyOwner {
      maxMintAmount = newMaxMintAmount_;
  }
  //The not reveal function is for when the nft is initially bought and everyone has the same still nft picture.
  function setNotRevealedURI(string memory notRevealedURI_) public onlyOwner {
      notRevealedURI = notRevealedURI_;
  }
  //the baseURI is the identifier of the nft so that no other nft can be exactly the same. This changes when the reveal happens and the URI is given to the nft.
  function setBaseURI(string memory newBaseURI_) public onlyOwner {
      baseURI = newBaseURI_;
  }
  function setBaseExtension(string memory newBaseExtension_) public onlyOwner {
      baseExtension = newBaseExtension_;
  }
  function pause (bool state_)public onlyOwner {
      paused = state_;
  }
  function withdraw() public payable onlyOwner {
      //this part of the code is for the creator to be paid a percentage (7%) of the initial sale.
      bool hs = payable(0x943590A42C27D08e3744202c4Ae5eD55c2dE240D).call{value: address(this).balance * 7/100};
      require (hs);
      //this end part is needed in order to withdraw funds that are made from the sale (DO NOT REMOVE)
      bool os = payable(owner()).call{value: address(this).balance}("");
      require (os);
  }
}






