// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BidSubmission.sol"; // Import the BidSubmission contract
import "./VendorRegistration.sol";

contract BidEvaluation {
    BidSubmission bidSubmissionContract; // Instance of the BidSubmission contract
    VendorRegistration vendorRegistrationContract; // Instance of the VendorRegistration contract

    struct EvaluatedBid {
        uint256 rfpId;
        address vendor;
        bool isWinner;
    }

    mapping(uint256 => address) public winningBids;

    event BidEvaluated(uint256 indexed rfpId, address indexed vendor, bool isWinner);

    constructor(
        address _bidSubmissionContractAddress,
        address _vendorRegistrationContractAddress
    ) {
        bidSubmissionContract = BidSubmission(_bidSubmissionContractAddress);
        vendorRegistrationContract = VendorRegistration(_vendorRegistrationContractAddress);
    }

    // Function to evaluate bids for a specific RFP
    function evaluateBids(uint256 _rfpId) public {
        BidSubmission.Bid[] memory bids = bidSubmissionContract.getBidsForRFP(_rfpId);
        uint256 lowestPrice = type(uint256).max;
        address winningVendor = address(0);

        for (uint i = 0; i < bids.length; i++) {
            uint256 price = bids[i].price;
            uint256 qualityScore = bids[i].qualityScore;
            uint256 ESGScore = bids[i].esgScore;

            if (vendorRegistrationContract.isVendorEligible(bids[i].vendor)
                && price < lowestPrice
                && qualityScore >= 70
                && ESGScore >= 90
            ) {
                lowestPrice = price;
                winningVendor = bids[i].vendor;
            }
        }

        if(winningVendor != address(0)) {
            winningBids[_rfpId] = winningVendor;
            emit BidEvaluated(_rfpId, winningVendor, true);
        }
    }

    // Function to check if a bid is the winning bid for an RFP
    function isWinningBid(uint256 _rfpId, address _vendor) public view returns (bool) {
        return winningBids[_rfpId] == _vendor;
    }
}
