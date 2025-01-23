//SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract MyContract {
    address public owner;

    struct Record {
        string data;
        address[] authorizedUsers;
    }

    mapping(uint => Record) private records;
    mapping(uint => address) private recordOwners;

    event RecordAdded(uint recordId, address owner);
    event RecordUpdated(uint recordId);
    event AccessGranted(uint recordId, address user);
    event AccessRevoked(uint recordId, address user);

    modifier onlyOwner(uint recordId) {
        require(recordOwners[recordId] == msg.sender, "Not authorized");
        _;
    }

    modifier onlyAuthorized(uint recordId) {
        bool isAuthorized = false;
        for (uint i = 0; i < records[recordId].authorizedUsers.length; i++) {
            if (records[recordId].authorizedUsers[i] == msg.sender) {
                isAuthorized = true;
                break;
            }
        }
        require(isAuthorized || recordOwners[recordId] == msg.sender, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addRecord(uint recordId, string memory data) public {
        require(records[recordId].authorizedUsers.length == 0, "Record already exists");
        records[recordId].data = data;
        recordOwners[recordId] = msg.sender;
        emit RecordAdded(recordId, msg.sender);
    }

    function updateRecord(uint recordId, string memory data) public onlyOwner(recordId) {
        records[recordId].data = data;
        emit RecordUpdated(recordId);
    }

    function getRecord(uint recordId) public view onlyAuthorized(recordId) returns (string memory) {
        return records[recordId].data;
    }

    function grantAccess(uint recordId, address user) public onlyOwner(recordId) {
        records[recordId].authorizedUsers.push(user);
        emit AccessGranted(recordId, user);
    }

    function revokeAccess(uint recordId, address user) public onlyOwner(recordId) {
        for (uint i = 0; i < records[recordId].authorizedUsers.length; i++) {
            if (records[recordId].authorizedUsers[i] == user) {
                records[recordId].authorizedUsers[i] = records[recordId].authorizedUsers[records[recordId].authorizedUsers.length - 1];
                records[recordId].authorizedUsers.pop();
                emit AccessRevoked(recordId, user);
                break;
            }
        }
    }
}