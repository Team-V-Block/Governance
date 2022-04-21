// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


contract Governance {
//Hash roles using keccak256 hashing
    bytes32 public constant STUDENT_ROLE = keccak256("STUDENT_ROLE");
    bytes32 public constant TEACHER_ROLE = keccak256("TEACHER_ROLE");
    bytes32 public constant CHAIRMAN_ROLE = keccak256("CHAIRMAN_ROLE");

    address[] accounts;
    mapping(bytes32 => address[]) private roles;
    constructor (){
        //Grant chairman role to the contract deployer
       grantRole(CHAIRMAN_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public returns (bool) {
        if (role == CHAIRMAN_ROLE) {
            require (roles[role].length == 0, "Can't assign CHAIRMAN_ROLE to more than one account");
        }
        roles[role].push(account);
        return true;
    }
    function getRoleMembers (bytes32 role) public view returns (address [] memory) {
        return roles[role];
    }

    function getRoleChairman () public view returns(address){
        return roles[CHAIRMAN_ROLE][0];
    }

}