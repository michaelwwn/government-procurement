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
            // Assuming bidDetails is "price,qualityScore, ESGScore" i.e. 100,90,90
            string[] memory details = splitBidDetails(bids[i].bidDetails);
            uint256 price = parseUint(details[0]);
            uint256 qualityScore = parseUint(details[1]);
            uint256 ESGScore = parseUint(details[2]);

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

    function splitBidDetails(string memory bidDetails) internal pure returns (string[] memory) {
        bytes memory bidDetailsBytes = bytes(bidDetails);
        uint256 commaCount = 0;

        // Count how many commas are in the string
        for(uint256 i = 0; i < bidDetailsBytes.length; i++) {
            if (bidDetailsBytes[i] == ",") {
                commaCount++;
            }
        }

        // There will be commaCount + 1 number of elements in the resulting array
        string[] memory parts = new string[](commaCount + 1);
        uint256 partIndex = 0;
        bytes memory part = "";

        // Split the string by commas
        for(uint256 i = 0; i < bidDetailsBytes.length; i++) {
            if (bidDetailsBytes[i] == ",") {
                parts[partIndex] = string(part);
                partIndex++;
                part = "";
            } else {
                part = abi.encodePacked(part, bidDetailsBytes[i]);
            }
        }

        // Add the last part after the final comma, or the whole string if no commas
        parts[partIndex] = string(part);

        return parts;
    }

    // Function to convert string to uint
    function parseUint(string memory _a) internal pure returns (uint256) {
        bytes memory bresult = bytes(_a);
        uint256 mint = 0;
        for (uint256 i = 0; i < bresult.length; i++) {
            if ((uint8(bresult[i]) >= 48) && (uint8(bresult[i]) <= 57)) {
                mint *= 10;
                mint += uint8(bresult[i]) - 48;
            } else {
                break;
            }
        }
        return mint;
    }
}
