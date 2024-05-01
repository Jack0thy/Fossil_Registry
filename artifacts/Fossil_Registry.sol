// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MuseumFossilRegistry is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    struct Fossil {
        string name;
        string description;
        string ipfsHash;
        address creator;
        uint256 creationDate;
        address currentOwner;
        address[] ownershipHistory;
    }

    mapping(uint256 => Fossil) public fossils;
    mapping(uint256 => bool) private _exists; // Mapping to track existence of fossils

    event FossilCreated(uint256 indexed tokenId, string name, address creator);

    constructor() ERC721("MuseumFossil", "MF") {}

    function createFossil(string memory _name, string memory _description, string memory _ipfsHash) external {
        uint256 newTokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, newTokenId);

        address[] memory emptyHistory; // Initialize empty ownership history array

        Fossil memory newFossil = Fossil({
            name: _name,
            description: _description,
            ipfsHash: _ipfsHash,
            creator: msg.sender,
            creationDate: block.timestamp,
            currentOwner: msg.sender,
            ownershipHistory: emptyHistory // Set empty ownership history array
        });

        fossils[newTokenId] = newFossil;
        _exists[newTokenId] = true; // Mark the fossil as existing
        _tokenIdCounter.increment();

        emit FossilCreated(newTokenId, _name, msg.sender);
    }

    function transferOwnership(uint256 _tokenId, address _newOwner) external {
        require(ownerOf(_tokenId) == msg.sender, "You are not the current owner of this fossil");
        _transfer(msg.sender, _newOwner, _tokenId);
        fossils[_tokenId].currentOwner = _newOwner;
        fossils[_tokenId].ownershipHistory.push(msg.sender);
    }

    function getFossil(uint256 _tokenId) external view returns (
        string memory name,
        string memory description,
        string memory ipfsHash,
        address creator,
        uint256 creationDate,
        address currentOwner,
        address[] memory ownershipHistory
    ) {
        // require(_exists(_tokenId), "Fossil with this token ID does not exist");

        Fossil memory fossil = fossils[_tokenId];
        return (fossil.name, fossil.description, fossil.ipfsHash, fossil.creator, fossil.creationDate, fossil.currentOwner, fossil.ownershipHistory);
    }

    // function _exists(uint256 _tokenId) internal view returns (bool) {
    //     return _exists[_tokenId]; // Check if the fossil exists
    // }
}