// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Governance {
    //Hash roles using keccak256 hashing
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant CHAIRMAN_ROLE = keccak256("CHAIRMAN_ROLE");

    bool public votingAllowed = true;
    bool public resultPublic = false;
    
    struct candidate {
        string name;   // short name (up to 32 bytes)
        uint256 voteCount; // number of accumulated votes
    }

    struct voter {
        bool voted;  // if true, that person already voted
        uint256 vote;   // index of the voted candidate
    }

    // A dynamically-sized array of `candidate` structs.
    candidate[] public candidates;
    address[] shareholderArray;

    mapping(address => bytes32) shareholders;
    mapping(address => voter) public voters;
   
    modifier isValidRole(bytes32 role) {
        require (role == STUDENT_ROLE || role == TEACHER_ROLE || role == CHAIRMAN_ROLE, "Cannot assign invalid role!");
        _;
    }

    modifier isShareholder () {
        require (shareholders[msg.sender] != 0, "Voter must be a shareholder");
        _;
    }

    modifier hasNotVoted () {
        require (!voters[msg.sender].voted, "Shareholder has already voted");
        _;
    }

    modifier canChangeVotingAllowed (){
        require(shareholders[msg.sender] == CHAIRMAN_ROLE, "Only account with CHAIRMAN ROLE can change voting allowed");
        _;
    }

    modifier canChangeResultStatus (){
        require(shareholders[msg.sender] == CHAIRMAN_ROLE || shareholders[msg.sender] == TEACHER_ROLE, "Only accounts with CHAIRMAN or TEACHER ROLE can change result status");
        _;
    }

    modifier canViewResult () {
        if (shareholders[msg.sender] == STUDENT_ROLE) {
            require(resultPublic == true, "Result not yet public");
        }
        _;
    }

    modifier canAddCandidates (){
        require(shareholders[msg.sender] == CHAIRMAN_ROLE || shareholders[msg.sender] == TEACHER_ROLE, "Only accounts with CHAIRMAN or TEACHER ROLE can add candidates");
        _;
    }

    constructor (){
        //Grant chairman role to the contract deployer
       grantRole(CHAIRMAN_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public isValidRole(role) returns (bool) {
        require (account != address(0));
        require(shareholders[msg.sender] == CHAIRMAN_ROLE, "Only accounts with CHAIRMAN ROLE can grant roles")
        shareholders[account] = role;
        shareholderArray.push(account);
        return true;
    }

    function vote(uint256 candidateIndex) public isShareholder hasNotVoted returns (bool) {
        require(votingAllowed == true, "Voting not allowed");
        candidates[candidateIndex].voteCount += 1;
        voters[msg.sender] = voter({voted: true, vote: candidateIndex});
        return true;
    }

    function getRole (address account) public view returns (bytes32) {
        return shareholders[account];
    }

    function changeVotingAllowed (bool status) public canChangeVotingAllowed {
        votingAllowed = status;
    }

    function votingResult () public view canViewResult returns (candidate[] memory) {
        return candidates;
    }

    function changeResultStatus (bool status) public canChangeResultStatus {
        resultPublic = status;
    }

    function addCandidates (string[] calldata names) public canAddCandidates {
        require(names.length <= 50, "Number of candidates is greater than amount allowable");
        for (uint i=0; i<names.length; i++) {
            candidates.push(candidate({name: names[i], voteCount: 0}));
        }
    }
}