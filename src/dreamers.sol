// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;


import "ERC721A/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract Dreamers is ERC721A, Ownable, Pausable, ReentrancyGuard {
  uint256 public constant PRESALEQTY = 5000;
  uint256 public  teamQtyMinted;
  string private _baseTokenURI;


    struct PresaleProps {
    bytes32 merkleRoot;
    uint32 startTime;
    uint64 price;
    uint64 maxPerAddress;
  }

  PresaleProps public presaleProps;

  struct PublicSaleProps {
    uint32 startTime;
    uint64 price;
    uint64 maxPerAddress;
  }

  PublicSaleProps public publicSaleProps;

    struct TeamMintProps {
    bytes32 merkleRoot;
    uint64 totalMintQty;
    uint64 maxPerAddress;
  }

  TeamMintProps public teamMintProps;
    constructor() ERC721A("Dreamer", "DRM"){

    }


    ///@notice triggers when there is an emergency
    function pause() external onlyOwner{
        _pause();
    }
    function unPause() external onlyOwner{
        _unpause();
    }


     function _beforeTokenTransfers(
      address from,
      address to,
      uint256 startTokenId,
      uint256 quantity
  ) internal virtual whenNotPaused override {
    super._beforeTokenTransfers(from, to, startTokenId, quantity);
  }



    function setPresaleProps(
    bytes32 merkleRoot,
    uint32 presaleStartTime,
    uint64 presalePriceWei,
    uint64 maxPerAddressDuringPresaleMint
  ) external onlyOwner {
    presaleProps.merkleRoot = merkleRoot;
    presaleProps.startTime = presaleStartTime;
    presaleProps.price = presalePriceWei;
    presaleProps.maxPerAddress = maxPerAddressDuringPresaleMint;
  }
   function setMerkleRoot(bytes32 root) external onlyOwner {
    presaleProps.merkleRoot = root;
  }


  function presaleMint(bytes32[] calldata _merkleProof, uint64 quantity)
    external
    payable
    nonReentrant
  {
    uint256 price = uint256(presaleProps.price);
    uint256 saleStartTime = uint256(presaleProps.startTime);
    uint64 maxPerAddress = presaleProps.maxPerAddress;
    require(price != 0, "whitelist sale has not begun yet");
    require(
      saleStartTime != 0 && block.timestamp >= saleStartTime,
      "presale has not begun yet"
    );
    require(totalSupply() + quantity <= 10000, "reached max supply");
    bytes32 leaf = keccak256 (abi.encodePacked(msg.sender));
    require(
      MerkleProof.verify(_merkleProof, presaleProps.merkleRoot, leaf),
      "invalid whitelist proof"
    );
    require(
      _getAux(_msgSender()) + quantity <= maxPerAddress,
      "can not mint this many"
    );
    _safeMint(msg.sender, quantity);
    _setAux(_msgSender(), _getAux(_msgSender()) + quantity); 
    refundIfOver(price * quantity);
  }



  function refundIfOver(uint256 price) private {
    require(msg.value >= price, "need to send more ETH");
    if (msg.value > price) {
      payable(msg.sender).transfer(msg.value - price);
    }
  }

  


  function endpRESaleAndSetupPublicSale(
    uint32 publicSaleStartTime,
    uint64 publicSalePriceWei,
    uint64 maxPerAddressDuringPublicSaleMint
  ) external onlyOwner {
    presaleProps.startTime = 0;

    publicSaleProps.startTime = publicSaleStartTime;
    publicSaleProps.price = publicSalePriceWei;
    publicSaleProps.maxPerAddress = maxPerAddressDuringPublicSaleMint;
  }

  function publicSaleMint(uint64 quantity)
    external
    payable
    nonReentrant
  {
    uint256 price = uint256(publicSaleProps.price);
    uint256 startTime = uint256(publicSaleProps.startTime);
    uint64 maxPerAddress = publicSaleProps.maxPerAddress;
    require(price != 0, "public sale has not begun yet");
    require(
      startTime != 0 && block.timestamp >= startTime,
      "public sale has not begun yet"
    );
    require(totalSupply() + quantity <= 10000, "reached max supply");
    require(
      _numberMinted(_msgSender()) - _getAux(_msgSender()) + quantity
        <= maxPerAddress,
      "can not mint this many"
    );
    _safeMint(msg.sender, quantity);
    refundIfOver(price * quantity);
  }

   function setTeamMintProps(
    bytes32 merkleRoot,
    uint64 maxPerAddressForEachTeamMember
  ) external onlyOwner {
    teamMintProps.merkleRoot = merkleRoot;
    teamMintProps.maxPerAddress = maxPerAddressForEachTeamMember;
  }

  function teamMint(bytes32[] calldata _merkleProof, uint64 quantity)
    external
    nonReentrant
  {
    uint64 maxPerAddress = teamMintProps.maxPerAddress;
    require(maxPerAddress != 0, "Owner is yet to set quantity for each devs");
    require(totalSupply() + quantity <= 10000, "reached max supply");
    bytes32 leaf = keccak256 (abi.encodePacked(msg.sender));
    require(
      MerkleProof.verify(_merkleProof, teamMintProps.merkleRoot, leaf),
      "invalid TeamMember proof"
    );
    require(
      _getAux(_msgSender()) + quantity <= maxPerAddress,
      "can not mint this many"
    );
    _safeMint(msg.sender, quantity);
    _setAux(_msgSender(), _getAux(_msgSender()) + quantity);  
  }


  function _baseURI() internal view virtual override returns (string memory) {
    return _baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    _baseTokenURI = baseURI;
  }


  function withdrawMoney() external onlyOwner nonReentrant {
    (bool success,) = msg.sender.call{value: address(this).balance}("");
    require(success, "transfer failed");
  }


}
