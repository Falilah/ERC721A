// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.10;


import "ERC721A/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Strings.sol";


contract DRM is ERC721A, Ownable, ReentrancyGuard {
    uint256 public constant PRESALE_MAX = 5000;
    uint256 public constant TEAM_MAX = 100; 
    uint256 public constant TOTAL_MAX = 10000; 
    uint256 public constant MAX_SALE_QUANTITY = 3; 
    uint256 public constant AMOUNTFORTEAM = 5;
    uint256 public whitelistCount;
    uint256 public reserveCount;

    using Strings for uint256;


    string private baseTokenURI;
    bool public revealed;

    bytes4 private constant _INTERFACE_ID_ERC2981 = 0x2a55205a;


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


  /////////////////MAPPINGs/////////////////////////////
   mapping (address => bool) public teamMember;
  mapping(address => bool) public memberHasMinted;


  constructor() ERC721A("Dreamer", "DRM"){

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
    require(totalSupply() + quantity <= TOTAL_MAX , "reached max supply");
    bytes32 leaf = keccak256 (abi.encodePacked(msg.sender));
    require(
      MerkleProof.verify(_merkleProof, presaleProps.merkleRoot, leaf),
      "invalid whitelist proof"
    );
    require(numberMinted(msg.sender) + quantity <= maxPerAddress,
      "can not mint this many"
    );
    refundIfOver(price * quantity);
    _safeMint(msg.sender, quantity);
  }



  function refundIfOver(uint256 price) private {
    require(msg.value >= price, "need to send more ETH");
    if (msg.value > price) {
      uint dif = msg.value - price;
     (bool success,) = payable(msg.sender).call{value: dif}("");
     require(success, "transfer failed");
    }
  }


   function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }


  function endPreSaleAndSetupPublicSale(
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
    require(numberMinted(msg.sender) + quantity <= maxPerAddress,
      "can not mint this many"
    );
    refundIfOver(price * quantity);
    _safeMint(msg.sender, quantity);
  }
  function addTeamMember(address member)  external onlyOwner{
    teamMember[member] = true;

  }
  function teamMint() external nonReentrant{
    require(teamMember[msg.sender] == true, "not a member on the team");
    require(memberHasMinted[msg.sender] == false, "teamMint: you have previously minted your NFT");
    require(totalSupply() + AMOUNTFORTEAM <= 10000, "reached max supply");
    memberHasMinted[msg.sender] = true;
    _safeMint(msg.sender, AMOUNTFORTEAM);


  }


  function _baseURI() internal view virtual override returns (string memory) {
    return baseTokenURI;
  }

  function setBaseURI(string calldata baseURI) external onlyOwner {
    baseTokenURI = baseURI;
  }

   function getOwnershipData(uint256 tokenId)
    external
    view
    returns (TokenOwnership memory)
  {
    return _ownershipOf(tokenId);
  }

  function tokenURI(uint256 _tokenId) public view override returns (string memory) {
		require(_exists(_tokenId), "ERC721Metadata: URI query for nonexistent token");
		return string(abi.encodePacked(baseTokenURI, _tokenId.toString(), ".json"));
	}



  function withdrawMoney() external onlyOwner nonReentrant {
    uint totalAmount = address(this).balance;
    (bool success, ) = owner().call{value: totalAmount}("");
    require(success, "transfer failed");
  }






// ipfs://QmcKBFgWTEayKPrKhaQhz4cmAqjzzhncztpyJS44YyF4dv/



  


}