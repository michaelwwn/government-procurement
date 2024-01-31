// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BidEvaluation.sol"; // Import the BidEvaluation contract

contract ApprovalWorkflow {
    BidEvaluation bidEvaluationContract; // Instance of the BidEvaluation contract

    enum ApprovalStatus { Pending, Approved, Rejected }
    struct BidApproval {
        uint256 rfpId;
        address vendor;
        ApprovalStatus status;
    }

    mapping(uint256 => BidApproval) public approvals;

    event BidApproved(uint256 indexed rfpId, address indexed vendor);
    event BidRejected(uint256 indexed rfpId, address indexed vendor);

    constructor(address _bidEvaluationContractAddress) {
        bidEvaluationContract = BidEvaluation(_bidEvaluationContractAddress);
    }

    // Function to approve a bid
    function approveBid(uint256 _rfpId, address _vendor) public {
        require(bidEvaluationContract.isWinningBid(_rfpId, _vendor), "Vendor is not the winning bidder");

        approvals[_rfpId] = BidApproval({
            rfpId: _rfpId,
            vendor: _vendor,
            status: ApprovalStatus.Approved
        });

        emit BidApproved(_rfpId, _vendor);
    }

    // Function to reject a bid
    function rejectBid(uint256 _rfpId, address _vendor) public {
        require(bidEvaluationContract.isWinningBid(_rfpId, _vendor), "Vendor is not the winning bidder");

        approvals[_rfpId] = BidApproval({
            rfpId: _rfpId,
            vendor: _vendor,
            status: ApprovalStatus.Rejected
        });

        emit BidRejected(_rfpId, _vendor);
    }

    // Function to check the approval status of a bid
    function getApprovalStatus(uint256 _rfpId) public view returns (ApprovalStatus) {
        return approvals[_rfpId].status;
    }

    function getApprovedVendor(uint256 _rfpId) public view returns (address) {
        require(approvals[_rfpId].status == ApprovalStatus.Approved, "Bid not approved");
        return approvals[_rfpId].vendor;
    }
}
