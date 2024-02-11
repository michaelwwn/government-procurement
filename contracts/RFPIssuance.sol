// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract RFPIssuance is Ownable(msg.sender){
    struct RFP {
        uint256 id;
        string title;
        string description;
        uint256 deadline;
        bool isActive;
    }

    uint256 private nextRfpId = 1;
    mapping(uint256 => RFP) public rfps;

    event RFPCreated(uint256 indexed rfpId, string title, uint256 deadline);
    event RFPUpdated(uint256 indexed rfpId, string title);
    event RFPDeactivated(uint256 indexed rfpId);

    // Function to issue a new RFP
    function issueRFP(string memory _title, string memory _description, uint256 _deadline) public onlyOwner{
        require(_deadline > block.timestamp, "Deadline should be in the future");

        RFP memory newRFP = RFP({
            id: nextRfpId,
            title: _title,
            description: _description,
            deadline: _deadline,
            isActive: true
        });

        rfps[nextRfpId] = newRFP;
        emit RFPCreated(nextRfpId, _title, _deadline);
        nextRfpId++;
    }

    // Function to update an RFP
    function updateRFP(uint256 _rfpId, string memory _title, string memory _description) public onlyOwner{
        require(rfps[_rfpId].isActive, "RFP is not active");
        rfps[_rfpId].title = _title;
        rfps[_rfpId].description = _description;

        emit RFPUpdated(_rfpId, _title);
    }

    // Function to deactivate an RFP
    function deactivateRFP(uint256 _rfpId) public onlyOwner{
        require(rfps[_rfpId].isActive, "RFP is already inactive");
        rfps[_rfpId].isActive = false;

        emit RFPDeactivated(_rfpId);
    }

    // Function to retrieve an RFP
    function getRFP(uint256 _rfpId) public view returns (RFP memory) {
        require(rfps[_rfpId].isActive, "RFP is not active");
        return rfps[_rfpId];
    }

    // Function to list all active RFPs
    function listRFPs() public view returns (RFP[] memory) {
        RFP[] memory activeRFPs = new RFP[](nextRfpId - 1);
        uint256 counter = 0;
        for(uint256 i = 1; i < nextRfpId; i++) {
            if(rfps[i].isActive) {
                activeRFPs[counter] = rfps[i];
                counter++;
            }
        }
        return activeRFPs;
    }
}
