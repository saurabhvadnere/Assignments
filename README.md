# Decentralized Voting System (Assignment 1)
## To create a decentralized voting system using Solidity, we will implement three primary functions:

1. Registration
2. Votecasting
3. Blacklisting

 ### Registration:
 -> Theregister function allows voters to register before the registration
 deadline.
 -> The modifier onlyBeforeDeadline ensures that registration can only happen before the deadline.
 
 ### VoteCasting:
 -> The vote function checks if the voter is registered and not blacklisted.
 -> If the voter tries to vote more than once, they are added to the blacklist, and their previous vote is removed.
 
 ### Blacklist:
 -> If a voter attempts to vote again, they are blacklisted, and their vote is removed.
 -> Attempt to vote multiple times from the same account to test the blacklist functionality.
 


Decentralized_Voting_system.sol

```solidity
// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.26;

contract DecentralizedVoting {
    address public owner;
    uint256 public registrationDeadline;
    mapping(address => bool) public registeredVoters; 
    mapping(address => bool) public hasVoted;
    mapping(address => bool) public blacklistedVoters; 
    mapping(uint256 => uint256) public votes;

    event VoterRegistered (address voter);
    event VoteCasted (address voter, uint256 candidate);
    event VoterBlacklisted (address voter);

    modifier onlyBeforeDeadline () {
        require(block.timestamp < registrationDeadline, "Registration period has ended");
        _;
    }
    modifier onlyRegistered() {
        require(registeredVoters[msg.sender], "You are not registered to vote");
        _;
    }

    constructor() {
        owner = msg.sender;
        registrationDeadline = 1723635000; // timestamp of  "August 14, 2024 5:00:00 PM"
    }

    function register() public onlyBeforeDeadline {
        require(!registeredVoters [msg.sender], "Already registered");
        registeredVoters [msg.sender] = true;
        emit VoterRegistered (msg.sender);
    }
    function vote(uint256 candidate) public onlyRegistered {
        require(!blacklistedVoters [msg.sender], "You are blacklisted from voting"); 
        if (hasVoted[msg.sender]) {
            blacklistedVoters [msg.sender] = true;
            votes[candidate]--;
                emit VoterBlacklisted (msg.sender);
        } else {
            hasVoted [msg.sender] = true;
            votes[candidate]++;
            emit VoteCasted (msg.sender, candidate);
        }
    }

    function getVotes (uint256 candidate) public view returns (uint256) {
        return votes[candidate];
    }
}
```


# Escrow Services for Online Marketplaces (Assignment 2)
### To create an escrow service for an online marketplace using Solidity, we will design a smart contract that allows sellers to list items, buyers to purchase them, and funds to be held in escrow until the buyer confirms receipt of the goods. We will also include a mechanism for dispute resolution

List Items:
Call the listItem function from the seller's account to list items.

Buy Items:
Call the buyItem function from the buyer's account to purchase items.

Confirm Receipt:
Call the confirmReceipt function from the buyer's account to confirm receipt and release funds.

Resolve Disputes:
Call the resolveDispute function from the owner's account to handle disputes.

```solidity
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
```


