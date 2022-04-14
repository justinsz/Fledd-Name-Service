// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// We first import some OpenZeppelin Contracts.
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import {StringUtils} from "./libraries/StringUtils.sol";
// We import another help function
import {Base64} from "./libraries/Base64.sol";

import "hardhat/console.sol";

// We inherit the contract we imported. This means we'll have access
// to the inherited contract's methods.
contract Domains is ERC721URIStorage {
  // Magic given to us by OpenZeppelin to help us keep track of tokenIds.
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string public tld;
  address payable public owner;
  // We'll be storing our NFT images on chain as SVGs
  string svgPartOne = '<svg version="1.0" xmlns="http://www.w3.org/2000/svg" width="400" height="460" viewBox="0 0 300 345"><g fill="#90f"><path d="M18.4 1.8c-2 1.2-8.4 15-11.5 24.4C2.9 38.6 1 51.2 1 66c0 37.2 13.6 68.5 40.8 94.2l8.2 7.6-6.4 9.6c-3.6 5.2-8.3 11.7-10.7 14.4l-4.2 4.9-6.1-.4c-4.9-.3-6.7 0-9.4 1.6-9.6 6.1-9.6 20.2 0 26.1 4.4 2.7 12.4 2.7 15.8 0 1.4-1.1 3.1-2 3.9-2 2.1 0 21 10.2 29.5 16 21.2 14.3 39.8 33.4 53.6 55 6.2 9.8 16.3 30.5 18 37 2.7 10.4 8 14.6 17.3 13.8 4.2-.3 6.4-1.1 8.3-2.9 2.9-2.7 5.7-7.9 6.8-12.4 1.2-5 11.9-26.5 17.6-35.5 13.8-21.6 32.4-40.7 53.6-55 8.5-5.8 27.4-16 29.5-16 .8 0 2.5.9 3.9 2 3.4 2.7 11.4 2.7 15.8 0 9.6-5.9 9.6-20 0-26.1-2.7-1.6-4.5-1.9-9.4-1.6l-6.1.4-4.2-4.9c-2.4-2.7-7.1-9.2-10.6-14.4l-6.4-9.6 8.9-8.4c11.2-10.8 20.4-22.9 26.4-35.1C295 105 299 87.6 299 66c0-21.1-4.2-39.4-12.9-56.9-4-7.8-4.3-8.1-7.6-8.1-5.8 0-24.4 7.9-36.6 15.5-13.7 8.6-29.7 23.5-39.3 36.5-6.4 8.6-14.8 22.7-16 26.7-.6 1.9-1.1 2-3.4 1.3-5.8-2-22.2-4-32.7-4-10.1 0-26 1.8-32.9 3.8-2.8.8-3 .6-6.7-6.5-11.6-22.6-31.8-44.7-52.8-57.8C41.7 6.3 22.4-.9 18.4 1.8zM30 5.6c10.3 4.2 21.9 10.3 31 16.3 8.4 5.5 27.6 23.6 33.6 31.6 2.9 3.9 12.2 18.8 15.6 25 2.7 4.9 3.6 5.1 17.4 3.1 18.2-2.6 37.1-2.1 52.6 1.3 5.6 1.3 6.9.4 11.3-7.6 12.9-23.7 32.9-44.9 54-57.5C257.1 10.9 274.6 3 278.4 3c1.7 0 5.5 7.1 9.9 18.5 4.2 10.8 5.2 14.5 7.1 25.6 2.7 15.6 2.9 19.9 1.1 31.4-5.1 33.9-17.7 58.9-39.9 79.4-9 8.3-9.3 9.4-4.5 18 3.2 5.6 13.1 18.4 16.4 21.1 1 .8 5 1.7 9.2 2.1 6.5.5 7.8 1 10 3.4 1.8 1.9 2.7 4.2 3 7.4.9 10.8-9 16.6-19.5 11.2-3.6-1.8-4-1.8-8.2-.3-4 1.5-12.5 5.8-17.2 8.7-.9.5-3.8 2.3-6.5 3.9-13.2 8.1-31.2 23.9-42.2 37.1-13.6 16.4-26.2 37.8-32.5 55.5-3.2 8.9-6.5 13.5-11.2 15.8-3.4 1.6-3.6 1.5-8-.8-5-2.7-6.2-4.5-10-15.2-2.9-8-10.5-23.9-14.7-30.5-1.5-2.4-2.7-4.7-2.7-5.2s-.3-1.1-.7-1.3c-.5-.2-2.6-2.9-4.7-6-2.1-3.2-4.6-6.5-5.5-7.5s-4.7-5.4-8.5-9.7c-13.2-14.8-33.1-30.4-51.9-40.4-9.5-5.1-14.2-6-18.5-3.8-6.1 3.1-14.1 1.4-17.5-3.8-2.1-3.1-2.4-8.4-.7-11.5 2.9-5.4 4.6-6.4 12.4-7 6.5-.6 7.9-1 10.6-3.6 7.6-7.3 18-23.2 18-27.6 0-1.9-1.2-3.9-4.1-6.6-14.7-13.7-23.2-24.9-31-40.7-5.4-11.1-10-25.2-11.2-34.6-.3-1.9-1.1-6.8-1.8-10.8-1.2-7.2-1-9.9 1.7-29.7C6.2 34.1 15.1 10.2 19.8 4.7c2-2.2 2.7-2.2 10.2.9z"/><path d="M20.8 15.7c-2.5 3-5.1 10-8.3 21.9-3.7 13.8-4 39.5-.6 54.1 5.2 22.9 15.5 41.7 31.2 57.6 10.3 10.5 12.1 10.9 15.6 3.6 7.7-16.2 10.5-49.8 5.8-70.4C58.8 57.6 47.7 36 32.2 19.7c-5.8-6-8.8-7-11.4-4zm15.1 12.8C49.7 45.5 57.7 63 62 85c1.9 9.8 2.2 13.7 1.7 27-.4 16-1.6 23-6.4 37.4l-2.5 7.8-7-6.8c-16.5-16.2-26.6-33.8-33-57.4-2-7.4-2.3-10.8-2.2-27 0-20.2 1.1-26.5 7.6-43.3l3-7.9 3.5 3.4c1.9 1.8 6.1 6.4 9.2 10.3zM267 20.8c-28.8 29.7-40.8 78-29.8 119.7 2.7 10.3 5.3 16.4 7.3 17.2 2.5.9 5.9-1.4 13-8.6 7.5-7.8 14.8-17.9 19.8-27.6 5.2-10.2 6.5-13.8 9.8-26.5 5.2-19.7 5-41.5-.6-60.3-6.9-23.6-8.8-25-19.5-13.9zm16.6 13.1c3.6 12.6 4.7 22.8 4.1 38.1-.8 18.1-4.2 31.1-12.5 47.6-5 10-13.9 21.9-23 30.8l-7 6.8-2.5-7.8c-4.8-14.4-6-21.4-6.4-37.4-.5-13.3-.2-17.2 1.7-27 5-25.6 15.5-46.1 33.4-64.8l5.1-5.3 2.3 5.2c1.3 2.9 3.4 9.1 4.8 13.8zm-236-11.1c.5.5 4.5 3.3 8.8 6.3C67 36.2 80.6 49.3 88.6 59.9c3.6 4.7 9.3 14.1 12.7 20.9 3.4 6.7 7 12.5 7.9 12.7.9.3 5.2-.3 9.5-1.5 4.3-1.1 13.1-2.5 19.5-3.2 13.7-1.4 30-.2 43.1 3.2 4.3 1.2 8.6 1.8 9.5 1.5.9-.2 4.5-6 7.9-12.7 3.4-6.8 9.1-16.2 12.7-20.9 8.2-10.9 21.8-23.8 33-31.4 8.8-6 10.2-8.6 2.4-4.5-9.5 5-24.1 17.7-33.7 29.5-7.8 9.6-11 14.5-16.5 25.1-6.6 13-6.4 12.9-16.7 10.5-19.8-4.7-41.5-4.7-60.1 0-4.2 1-8.3 1.6-9.2 1.3-.8-.3-3.9-5.2-6.7-10.7-7-14-14.4-24.2-25.9-36.2-7.1-7.5-17.4-15.6-24.6-19.4-3.9-2.1-7.7-2.9-5.8-1.3z"/><path d="M46 25.3c0 .7 2.1 4.6 4.7 8.7 6.4 10.4 13.5 25.8 16.6 36.5 7.6 26.2 6.8 56.9-2.2 82.9-1.7 4.9-3.1 9.5-3.1 10.2 0 .6 2.4 3.4 5.3 6.1 31.3 28.9 47.1 50.4 60 81.8 4.3 10.6 10.4 30.2 11.2 36.1.2 1.6 1.1 6.9 1.9 11.8.9 4.9 1.6 9.9 1.6 11.2 0 3.9 3.4 6.4 8.5 6.4 5.6 0 7-2 7.9-10.8.7-6.6 4.7-26.2 6.6-32.2.6-1.9 1.3-4.2 1.5-5.1 1.1-5.2 6.5-19.1 11-28.5 3.6-7.6 12.2-22.6 13.4-23.4.4-.3 1-1.2 1.3-2 2.2-6 21-27 41.2-45.9 2.5-2.4 4.6-4.9 4.6-5.5 0-.7-1.1-4.6-2.5-8.7-6.4-18.5-8.9-35.2-8-53.2 1.1-22.8 7.5-43.7 19.8-64.2 6.2-10.3 6.8-11.6 6.4-12.8-1.1-3.4-16.7 24.1-21.4 37.8-6 17.8-6.7 22.5-6.7 45.5 0 23.6 1.2 31.5 7.6 48l2.8 7.5-5.2 4.4C214.4 181.5 196 203 185 221c-14.4 23.7-26 56.4-28.5 80.5-1.4 13.9-1 13-6.5 13s-5.1.9-6.5-13c-2.5-24.1-14.1-56.8-28.5-80.5-11-18-29.4-39.5-45.8-53.1l-5.2-4.4 2.8-7.5c6.3-16.3 7.6-24.5 7.7-47.5 0-14.2-.4-23-1.4-27-4-18-12.8-38.6-21.8-51.3-4.5-6.4-5.3-7.1-5.3-4.9z"/><path d="M55.8 174.7c-.9 1-3.6 4.9-6 8.8-2.5 3.8-5.6 8.2-6.9 9.6-9.3 10-11.1 14.8-7.3 19 1 1.2 5.5 3.9 9.9 6.1 30.3 15.2 56.6 38.5 75.3 66.8 5.3 7.9 8.2 11.3 9 10.5 1.4-1.4-12.6-21.7-23.6-34-16.3-18.4-36.4-33.9-58.7-45.2-10-5-11.4-6.1-11.8-8.6-.3-2 .2-3.3 1.8-4.5 3.5-2.8 14.2-16.9 17.7-23.2 1.8-3.3 3.6-5.9 4-5.7.4.1 5.3 4.5 10.9 9.7 29 26.9 48.2 59.3 58.2 97.9 2.1 8.1 3.7 12.6 4.1 11.5 1-2.6-1.2-12.8-6-27.3-9.5-28.9-24.6-53.7-46.8-76.8C69.7 179 62.3 173 59.3 173c-1.1 0-2.7.8-3.5 1.7zm179.2.9c-6 4.6-24.3 23.6-30.1 31.4-9.6 12.9-12.3 17.2-17.8 28-3 5.8-5.7 10.9-6.1 11.5-1.1 1.6-6.8 16.7-7.6 20-.4 1.6-.9 3.4-1.3 4-.3.5-.6 1.5-.7 2.1s-.9 3.6-1.7 6.5c-2.1 7.5-3 13.6-2.2 15 .4.6 2-4 3.6-10.2 8.2-32 20.9-57.2 41.3-81.7 6.3-7.6 26.3-27.2 28.4-27.9.4-.2 2.2 2.4 4 5.7 3.5 6.3 14.2 20.4 17.7 23.2 1.6 1.2 2.1 2.5 1.8 4.5-.4 2.5-1.8 3.6-11.8 8.6-22.3 11.3-42.4 26.8-58.7 45.2-12 13.4-25 32.6-23.4 34.3.8.7.1 1.5 8.7-10.8 9.8-14.2 13.6-18.8 25.4-30.5 15.3-15.4 30.6-26.4 51.2-37 8.3-4.2 9.4-5.1 10.2-8.3 1.2-4.1.5-5.6-4.7-11.4-2-2.2-6.9-8.6-10.7-14.2-8-11.5-9.7-12.4-15.5-8z"/></g><text x="32.5" y="231" font-size="27" fill="#fff" filter="url(#A)" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string svgPartTwo = 'eth.fledd</text></svg>';

  error Unauthorized();
  error AlreadyRegistered();
  error InvalidName(string name);

  mapping(string => address) public domains;
  mapping(string => string) public records;
  mapping (uint => string) public names;

  constructor(string memory _tld) ERC721 ("Fledd Name Service", "FNS") payable {
    owner = payable(msg.sender);
    tld = _tld;
    console.log("%s name service deployed", _tld);
  }

  function price(string calldata name) public pure returns(uint) {
  uint len = StringUtils.strlen(name);
  require(len > 0);
  if (len == 3) {
    return 2 * 10**17; // 5 MATIC = 5 000 000 000 000 000 000 (18 decimals). We're going with 0.5 Matic cause the faucets don't give a lot
  } else if (len == 4) {
    return 1 * 10**17; // To charge smaller amounts, reduce the decimals. This is 0.3
  } else {
    return 1 * 10**17;
  }
}

  function valid(string calldata name) public pure returns(bool) {
  return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
}

  function register(string calldata name) public payable {
      if (domains[name] != address(0)) revert AlreadyRegistered();
      if (!valid(name)) revert InvalidName(name);
    require(domains[name] == address(0));

    uint256 _price = price(name);
    require(msg.value >= _price, "Not enough Matic paid");
    
    // Combine the name passed into the function  with the TLD
    string memory _name = string(abi.encodePacked(name, ".", tld));
    // Create the SVG (image) for the NFT with the name
    string memory finalSvg = string(abi.encodePacked(svgPartOne, _name, svgPartTwo));
    uint256 newRecordId = _tokenIds.current();
    uint256 length = StringUtils.strlen(name);
    string memory strLen = Strings.toString(length);

    console.log("Registering %s.%s on the contract with tokenID %d", name, tld, newRecordId);

    // Create the JSON metadata of our NFT. We do this by combining strings and encoding as base64
    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        _name,
        '", "description": "A domain on the Fledd name service", "image": "data:image/svg+xml;base64,',
        Base64.encode(bytes(finalSvg)),
        '","length":"',
        strLen,
        '"}'
      )
    );

    string memory finalTokenUri = string( abi.encodePacked("data:application/json;base64,", json));

    console.log("\n--------------------------------------------------------");
    console.log("Final tokenURI", finalTokenUri);
    console.log("--------------------------------------------------------\n");

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);
    domains[name] = msg.sender;
    names[newRecordId] = name;
    _tokenIds.increment();
  }


  function getAddress(string calldata name) public view returns (address) {
      return domains[name];
  }

  function setRecord(string calldata name, string calldata record) public {
      // Check that the owner is the transaction sender
      if (msg.sender != domains[name]) revert Unauthorized();
  records[name] = record;
  }

  function getRecord(string calldata name) public view returns(string memory) {
      return records[name];
  }

  modifier onlyOwner() {
  require(isOwner());
  _;
}

function isOwner() public view returns (bool) {
  return msg.sender == owner;
}

function withdraw() public onlyOwner {
  uint amount = address(this).balance;
  
  (bool success, ) = msg.sender.call{value: amount}("");
  require(success, "Failed to withdraw Matic");
} 

function getAllNames() public view returns (string[] memory) {
  console.log("Getting all names from contract");
  string[] memory allNames = new string[](_tokenIds.current());
  for (uint i = 0; i < _tokenIds.current(); i++) {
    allNames[i] = names[i];
    console.log("Name for token %d is %s", i, allNames[i]);
  }

  return allNames;
}

}