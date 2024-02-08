// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./RFPIssuance.sol"; // Import the RFPIssuance contract if it's in a separate file
import "./VendorRegistration.sol"; // Import the VendorRegistration contract if it's in a seperate file

contract BidSubmission {
    RFPIssuance rfpContract; // Instance of the RFPIssuance contract
    VendorRegistration vendorRegistrationContract;
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

    constructor(address _rfpContractAddress, address _vendorRegistrationContractAddress) {
        rfpContract = RFPIssuance(_rfpContractAddress);
        vendorRegistrationContract = VendorRegistration(_vendorRegistrationContractAddress);
    }

    // Function to submit a bid
    function submitBid(uint256 _rfpId, string memory _bidDetails) public {
        // Ensure the RFP exists and is active
        require(rfpContract.getRFP(_rfpId).isActive, "RFP is not active or does not exist");
        require(block.timestamp <= rfpContract.getRFP(_rfpId).deadline, "The deadline for this RFP has passed");
        // Ensure that the vendor has registered and is eligible
        require(vendorRegistrationContract.isVendorEligible(msg.sender), "Vendor is not eligible");
        require(vendorRegistrationContract.isVendorRegistered(msg.sender), "Vendor is not registered");

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
