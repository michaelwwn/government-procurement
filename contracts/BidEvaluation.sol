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

        // Placeholder for evaluation logic
        // We check and find the first bid in the array that has an eligible vendor if not, we move on the the next
        for (uint i = 0; i < bids.length; i++) {
            // Check if each vendor is eligible before proceeding with evaluation
            if (vendorRegistrationContract.isVendorEligible(bids[i].vendor)) {
                // In a real implementation, this would involve complex logic
                // For simplicity, we are just selecting the first bid that is eligible as the winner
                winningBids[_rfpId] = bids[i].vendor;
                emit BidEvaluated(_rfpId, bids[i].vendor, true);
                break;
            }
        }
    }

    // Function to check if a bid is the winning bid for an RFP
    function isWinningBid(uint256 _rfpId, address _vendor) public view returns (bool) {
        return winningBids[_rfpId] == _vendor;
    }
}
