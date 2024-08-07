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
        registrationDeadline = 1723635000;
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
