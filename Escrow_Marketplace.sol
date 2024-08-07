// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EscrowMarketplace {
    address public owner;

    struct Item {
        string name;
        uint256 price;
        address seller;
        address buyer;
        bool isSold;
    }

    mapping(string => Item) public items;

    event ItemListed(string name, uint256 price, address seller);
    event ItemBought(string name, uint256 price, address buyer);
    event ItemConfirmed(string name, address buyer);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlySeller(string memory _name) {
        require(items[_name].seller == msg.sender, "Only seller can call this function");
        _;
    }

    modifier onlyBuyer(string memory _name) {
        require(items[_name].buyer == msg.sender, "Only buyer can call this function");
        _;
    }

    modifier itemExists(string memory _name) {
        require(items[_name].seller != address(0), "Item does not exist");
        _;
    }

    modifier notSold(string memory _name) {
        require(!items[_name].isSold, "Item already sold");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function listItem(string memory _name, uint256 _price) public {
        require(items[_name].seller == address(0), "Item already listed");
        items[_name] = Item(_name, _price, msg.sender, address(0), false);
        emit ItemListed(_name, _price, msg.sender);
    }

    function buyItem(string memory _name) public payable itemExists(_name) notSold(_name) {
        Item storage item = items[_name];
        require(msg.value == item.price, "Incorrect value sent");
        item.buyer = msg.sender;
        emit ItemBought(_name, item.price, msg.sender);
    }

    function confirmReceipt(string memory _name) public onlyBuyer(_name) itemExists(_name) notSold(_name) {
        Item storage item = items[_name];
        item.isSold = true;
        payable(item.seller).transfer(item.price);
        emit ItemConfirmed(_name, msg.sender);
    }

    function resolveDispute(string memory _name) public onlyOwner itemExists(_name) notSold(_name) {
        Item storage item = items[_name];
        item.isSold = true;
        payable(item.buyer).transfer(item.price);
    }
}
