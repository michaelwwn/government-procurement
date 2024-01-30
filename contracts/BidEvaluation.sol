// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BidSubmission.sol"; // Import the BidSubmission contract

contract BidEvaluation {
    BidSubmission bidSubmissionContract; // Instance of the BidSubmission contract

    struct EvaluatedBid {
        uint256 rfpId;
        address vendor;
        bool isWinner;
    }

    mapping(uint256 => address) public winningBids;

    event BidEvaluated(uint256 indexed rfpId, address indexed vendor, bool isWinner);

    constructor(address _bidSubmissionContractAddress) {
        bidSubmissionContract = BidSubmission(_bidSubmissionContractAddress);
    }

    // Function to evaluate bids for a specific RFP
    function evaluateBids(uint256 _rfpId) public {
        BidSubmission.Bid[] memory bids = bidSubmissionContract.getBidsForRFP(_rfpId);

        // Placeholder for evaluation logic
        // In a real implementation, this would involve complex logic
        // For simplicity, we are just selecting the first bid as the winner
        if (bids.length > 0) {
            winningBids[_rfpId] = bids[0].vendor;
            emit BidEvaluated(_rfpId, bids[0].vendor, true);
        }
    }

    // Function to check if a bid is the winning bid for an RFP
    function isWinningBid(uint256 _rfpId, address _vendor) public view returns (bool) {
        return winningBids[_rfpId] == _vendor;
    }
}
