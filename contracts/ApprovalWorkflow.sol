// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BidEvaluation.sol"; // Import the BidEvaluation contract if it's in a separate file

contract ApprovalWorkflow {
    BidEvaluation bidEvaluationContract; // Instance of the BidEvaluation contract
    address public owner;
    mapping(address => bool) public whitelist; // Tracks whitelisted officer addresses
    
    enum ApprovalStatus { Pending, Approved, Rejected }
    struct BidApproval {
        uint256 rfpId;
        address vendor;
        ApprovalStatus status;
    }
    
    struct ApprovalData {
        uint256 approvalCount;
        mapping(address => bool) approvers;
        bool isApproved;
        bool isRejected;
    }
    
    mapping(uint256 => BidApproval) public approvals;
    mapping(uint256 => ApprovalData) private approvalData;
    
    uint256 public constant MIN_APPROVALS = 2;

    event BidApproved(uint256 indexed rfpId, address indexed vendor);
    event BidRejected(uint256 indexed rfpId, address indexed vendor);
    event OfficerAddedToWhitelist(address officer);
    event OfficerRemovedFromWhitelist(address officer);

    constructor(address _bidEvaluationContractAddress) {
        bidEvaluationContract = BidEvaluation(_bidEvaluationContractAddress);
        owner = msg.sender; // Setting the deployer as the owner
    }

    modifier onlyWhitelisted() {
        require(whitelist[msg.sender], "Caller is not whitelisted");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not the owner");
        _;
    }

    modifier notAlreadyApproved(uint256 _rfpId) {
        require(!approvalData[_rfpId].approvers[msg.sender], "Officer has already approved this bid");
        _;
    }

    function addToWhitelist(address _officer) public onlyOwner {
        whitelist[_officer] = true;
        emit OfficerAddedToWhitelist(_officer);
    }

    function removeFromWhitelist(address _officer) public onlyOwner {
        whitelist[_officer] = false;
        emit OfficerRemovedFromWhitelist(_officer);
    }

    function approveBid(uint256 _rfpId, address _vendor) public onlyWhitelisted notAlreadyApproved(_rfpId) {
        require(bidEvaluationContract.isWinningBid(_rfpId, _vendor), "Vendor is not the winning bidder");

        ApprovalData storage data = approvalData[_rfpId];
        data.approvers[msg.sender] = true;
        data.approvalCount++;

        if (data.approvalCount >= MIN_APPROVALS && !data.isApproved) {
            approvals[_rfpId] = BidApproval({
                rfpId: _rfpId,
                vendor: _vendor,
                status: ApprovalStatus.Approved
            });
            data.isApproved = true;
            emit BidApproved(_rfpId, _vendor);
        }
    }

    function rejectBid(uint256 _rfpId, address _vendor) public onlyWhitelisted notAlreadyApproved(_rfpId) {
        require(bidEvaluationContract.isWinningBid(_rfpId, _vendor), "Vendor is not the winning bidder");

        ApprovalData storage data = approvalData[_rfpId];
        data.approvers[msg.sender] = true;
        data.approvalCount++;

        if (data.approvalCount >= MIN_APPROVALS && !data.isRejected) {
            approvals[_rfpId] = BidApproval({
                rfpId: _rfpId,
                vendor: _vendor,
                status: ApprovalStatus.Rejected
            });
            data.isRejected = true;
            emit BidRejected(_rfpId, _vendor);
        }
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
