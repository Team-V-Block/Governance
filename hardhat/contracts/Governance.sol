// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract Governance {
    //Hash roles using keccak256 hashing
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant CHAIRMAN_ROLE = keccak256("CHAIRMAN_ROLE");

    //set variables for vote control
    bool public votingAllowed = true;
    bool public resultPublic = false;

    //define event for vote
    event shareholderVoted (address account, uint candidateIndex);

    event roleGranted (address account, bytes32 role);
    
    //define struct for candidate
    struct candidate {
        string name;   // short name (up to 32 bytes)
        uint256 voteCount; // number of accumulated votes
    }

    //define struct for voter
    struct voter {
        bool voted;  // if true, that person already voted
        uint256 vote;   // index of the voted candidate
    }

    //a dynamically-sized array of `candidate` structs.
    candidate[] candidates;

    //a dynamically-sized array of student structs.
    address[] shareholderArray;

    //define mapping for shareholders
    mapping(address => bytes32) shareholders;

    //define mapping for voters
    mapping(address => voter) voters;
   
    //define modifier to check if role is valid
    modifier isValidRole(bytes32 role) {
        require (role == STUDENT_ROLE || role == TEACHER_ROLE || role == CHAIRMAN_ROLE, "Cannot assign invalid role!");
        _;
    }

    //define modifier to check if account is a shareholder
    modifier isShareholder () {
        require (shareholders[msg.sender] != 0, "Voter must be a shareholder");
        _;
    }

    //define modifier to ensure that account had not voted
    modifier hasNotVoted () {
        require (!voters[msg.sender].voted, "Shareholder has already voted");
        _;
    }

    //define modifier to ensure account can change voting allowed status
    modifier canChangeVotingAllowed (){
        require(shareholders[msg.sender] == CHAIRMAN_ROLE, "Only account with CHAIRMAN ROLE can change voting allowed");
        _;
    }

    //define modifier to ensure account can change result viewing status
    modifier canChangeResultStatus (){
        require(shareholders[msg.sender] == CHAIRMAN_ROLE || shareholders[msg.sender] == TEACHER_ROLE, "Only accounts with CHAIRMAN or TEACHER ROLE can change result status");
        _;
    }

    //define modifier to check if account is allowed is allowed to view result
    modifier canViewResult () {
        if (shareholders[msg.sender] == STUDENT_ROLE) {
            require(resultPublic == true, "Result not yet public");
        }
        _;
    }

    //define modifier to check if account can add candidates
    modifier canAddCandidates (){
        require(shareholders[msg.sender] == CHAIRMAN_ROLE || shareholders[msg.sender] == TEACHER_ROLE, "Only accounts with CHAIRMAN or TEACHER ROLE can add candidates");
        _;
    }

    //define modifier to ensure account is roleless before assinging  role
    modifier roleless (address account){
        require (shareholders[account] != CHAIRMAN_ROLE && shareholders[account] != STUDENT_ROLE && shareholders[account] != TEACHER_ROLE, "Account has already been assigned a role");
        _;
    }

    //define contract contractor
    constructor (){
        //grant chairman role to the contract deployer
       shareholders[msg.sender] = CHAIRMAN_ROLE;
       shareholderArray.push(msg.sender);
    }

    //function to grant role to accounts
    function grantRole(bytes32 role, address account) public isValidRole(role) roleless(account) returns (bool) {
        require (account != address(0));//should not be able to grant role to address(0)
        require(shareholders[msg.sender] == CHAIRMAN_ROLE, "Only accounts with CHAIRMAN ROLE can grant roles");
        shareholders[account] = role;
        shareholderArray.push(account);
        emit roleGranted(account, role);
        return true;
    }

    //voting function
    function vote(uint256 candidateIndex) public isShareholder hasNotVoted returns (bool) {
        require(votingAllowed == true, "Voting not allowed"); //check if votting is currently allowed
        require(candidates.length > candidateIndex, "Candidate index out of bound"); //check if candidateIndex is in bound
        candidates[candidateIndex].voteCount += 1;
        voters[msg.sender] = voter({voted: true, vote: candidateIndex});
        emit shareholderVoted(msg.sender, candidateIndex);
        return true;
    }

    //function to get the role of a shareholder
    function getRole (address account) public view returns (bytes32) {
        return shareholders[account];
    }

    //function to chnage if voting is allowed
    function changeVotingAllowed (bool status) public canChangeVotingAllowed {
        votingAllowed = status;
    }

    //function to view voting result
    function votingResult () public view canViewResult returns (candidate[] memory) {
        return candidates;
    }

    //function to change result status privacy
    function changeResultStatus (bool status) public canChangeResultStatus {
        resultPublic = status;
    }

    //function to add candidates
    function addCandidates (string[] calldata names) public canAddCandidates {
        require(names.length <= 50, "Number of candidates is greater than amount allowable");
        for (uint i=0; i<names.length; i++) {
            candidates.push(candidate({name: names[i], voteCount: 0}));
        }
    }
}