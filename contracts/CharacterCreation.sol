// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "hardhat/console.sol";
import "./libraries/Base64.sol";
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CharacterCreation is ERC721{

    event NewCharacter(uint id, string name, uint dna, uint maxHp, uint attackDamage);
    


    uint HpDigits = 3;
    uint ADDigits = 2;
    uint dnaDigits = 16;


    uint RandHP = 10 ** HpDigits;
    uint RandAD = 10 ** ADDigits;
    uint dnaModulus = 10 ** dnaDigits;

    struct CharacterAttributes {
    uint id;
    string fstName;
    string lstName;
    uint hp;
    uint maxHp;
    uint attackDamage;
    uint level;
    uint exp;
    uint dna;
    }

    struct BigBoss {
      string name;
      string imageURI;
      uint hp;
      uint maxHp;
      uint attackDamage;
    }

    BigBoss public bigBoss;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;


    CharacterAttributes[] public characters;

     // We create a mapping from the nft's tokenId => that NFTs attributes.
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;

    // A mapping from an address => the NFTs tokenId. Gives me an ez way
    // to store the owner of the NFT and reference it later.
    mapping(address => uint256) public nftHolders;
    event CharacterNFTMinted(address sender, uint256 tokenId, uint256 characterIndex);
    event AttackComplete(address sender, uint newBossHp, uint newPlayerHp);

    constructor(string memory bossName, // These new variables would be passed in via run.js or deploy.js.
        string memory bossImageURI,
        uint bossHp,
        uint bossAttackDamage)ERC721("ZomRena", "ZR") {{
        bigBoss = BigBoss({
        name: bossName,
        imageURI: bossImageURI,
        hp: bossHp,
        maxHp: bossHp,
        attackDamage: bossAttackDamage

      });
        _tokenIds.increment();
    }
        }

    function _createCharacter(string memory _fstName, string memory _lstName, uint _dna, uint _hp, uint _attackDamage) private {
        uint _id = _tokenIds.current();
        characters.push(CharacterAttributes(_id, _fstName, _lstName,_hp, _hp, _attackDamage, 0, 0, _dna));
        // and fire it here
        emit NewCharacter(_id, _fstName, _dna, _hp, _attackDamage);
    }

    function _generateRandomHp(string memory _str) public view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % RandHP;
    }

    function _generateRandomAD(string memory _str) public view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % RandAD;
    }

    function _generateRandomDNA(string memory _str) public view returns (uint) {
        uint rand = uint(keccak256(abi.encodePacked(_str)));
        return rand % RandAD;
    }


    function createRandomCharacter(string memory _fstName, string memory _lstName) public {


        uint randDna = _generateRandomDNA(_fstName);
        uint randHP = _generateRandomHp(_lstName);
        uint randAD = _generateRandomAD(_fstName);
        _createCharacter(_fstName, _lstName, randDna, randHP, randAD);
    }

    function mintCharacterNFT(uint _characterIndex) external {
        uint256 newItemId = _tokenIds.current();

    // The magical function! Assigns the tokenId to the caller's wallet address.
        _safeMint(msg.sender, newItemId);


        nftHolderAttributes[newItemId] = CharacterAttributes({
          id: _characterIndex,
          fstName: characters[_characterIndex].fstName,
          lstName: characters[_characterIndex].lstName,
          hp: characters[_characterIndex].hp,
          maxHp: characters[_characterIndex].maxHp,
          attackDamage: characters[_characterIndex].attackDamage,
          level: characters[_characterIndex].level,
          exp: characters[_characterIndex].exp,
          dna: characters[_characterIndex].dna
    });
        nftHolders[msg.sender] = newItemId;

    // Increment the tokenId for the next person that uses it.
        _tokenIds.increment();
        emit CharacterNFTMinted(msg.sender, newItemId, _characterIndex); 
    }
   function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    CharacterAttributes memory charAttributes = nftHolderAttributes[_tokenId];

    string memory strHp = Strings.toString(charAttributes.hp);
    string memory strMaxHp = Strings.toString(charAttributes.maxHp);
    string memory strAttackDamage = Strings.toString(charAttributes.attackDamage);
    string memory strLevel = Strings.toString(charAttributes.level);
    string memory strExp = Strings.toString(charAttributes.exp);


    string memory json = Base64.encode(
        abi.encodePacked(
        '{"name": "',
        charAttributes.fstName, charAttributes.lstName,
        ' -- NFT #: ',
        Strings.toString(_tokenId),
        '", "description": "This is an NFT that lets you enter the Zombie Arena", "image": "',
        '", "attributes": [ { "trait_type": "Health Points", "value": ',strHp,', "max_value":',strMaxHp,'}, { "trait_type": "Attack Damage", "value": ',
        strAttackDamage,'}, { "trait_type": "level", "value": ', strLevel,'}, { "trait_type": "experience", "value": ', strExp,'} ]}'
        )
    );

    string memory output = string(
        abi.encodePacked("data:application/json;base64,", json)
    );
    
    return output;
    }
    function checkIfUserHasNFT() public view returns (CharacterAttributes memory) {
      // Get the tokenId of the user's character NFT
      uint256 userNftTokenId = nftHolders[msg.sender];
      // If the user has a tokenId in the map, return their character.
      if (userNftTokenId > 0) {
        return nftHolderAttributes[userNftTokenId];
      }
      // Else, return an empty character.
      else {
        CharacterAttributes memory emptyStruct;
        return emptyStruct;
       }
    }
    function getAllDefaultCharacters() public view returns (CharacterAttributes[] memory) {
      return characters;
    }
    function getBigBoss() public view returns (BigBoss memory) {
      return bigBoss;
    }
    function attackBoss() public{
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender];
        CharacterAttributes storage player = nftHolderAttributes[nftTokenIdOfPlayer];
        console.log("\nPlayer w/ character %s about to attack. Has %s HP and %s AD", player.fstName, player.hp, player.attackDamage);
        console.log("Boss %s has %s HP and %s AD", bigBoss.name, bigBoss.hp, bigBoss.attackDamage);
        require(player.hp > 0,
        "Error: Zombie must have HP to attack boss.");

        require(bigBoss.hp > 0,
     "Error: boss must have HP to attack character."
        );

        if (bigBoss.hp < player.attackDamage) {
            bigBoss.hp = 0;
            player.exp += 50;
            if (player.exp==100) {
                player.exp=0;
                player.level+=1;
                player.attackDamage+=10;
                player.maxHp+=50;
                console.log("You just leveled up you now have %s AD and %s HP", player.attackDamage, player.maxHp);
            } 
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        // Allow boss to attack player.
        if (player.hp < bigBoss.attackDamage) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }
        
        // Console for ease.
        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);
        emit AttackComplete(msg.sender, bigBoss.hp, player.hp);

        }
}