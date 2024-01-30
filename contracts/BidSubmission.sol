// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RFPIssuance.sol"; // Import the RFPIssuance contract if it's in a separate file

contract BidSubmission {
    RFPIssuance rfpContract; // Instance of the RFPIssuance contract

    struct Bid {
        uint256 rfpId;
        address vendor;
        string bidDetails;
        uint256 timestamp;
        bool isSubmitted;
    }

    mapping(uint256 => Bid[]) public bidsByRFP;
    mapping(address => Bid[]) public bidsByVendor;

    event BidSubmitted(uint256 indexed rfpId, address indexed vendor);

    constructor(address _rfpContractAddress) {
        rfpContract = RFPIssuance(_rfpContractAddress);
    }

    // Function to submit a bid
    function submitBid(uint256 _rfpId, string memory _bidDetails) public {
        // Ensure the RFP exists and is active
        require(rfpContract.getRFP(_rfpId).isActive, "RFP is not active or does not exist");
        require(block.timestamp <= rfpContract.getRFP(_rfpId).deadline, "The deadline for this RFP has passed");

        Bid memory newBid = Bid({
            rfpId: _rfpId,
            vendor: msg.sender,
            bidDetails: _bidDetails,
            timestamp: block.timestamp,
            isSubmitted: true
        });

        bidsByRFP[_rfpId].push(newBid);
        bidsByVendor[msg.sender].push(newBid);

        emit BidSubmitted(_rfpId, msg.sender);
    }

    // Function to get all bids for an RFP
    function getBidsForRFP(uint256 _rfpId) public view returns (Bid[] memory) {
        return bidsByRFP[_rfpId];
    }

    // Function to get all bids submitted by a vendor
    function getBidsByVendor(address _vendor) public view returns (Bid[] memory) {
        return bidsByVendor[_vendor];
    }
}
