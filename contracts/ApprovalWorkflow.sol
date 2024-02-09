// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./BidEvaluation.sol"; // Ensure this import path is correct for your project

contract ApprovalWorkflow is AccessControl {
    BidEvaluation bidEvaluationContract; // Instance of the BidEvaluation contract
    
    bytes32 public constant OFFICER_ROLE = keccak256("OFFICER_ROLE");
    
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
    event OfficerAdded(address officer);
    event OfficerRemoved(address officer);

    constructor(address _bidEvaluationContractAddress) {
        bidEvaluationContract = BidEvaluation(_bidEvaluationContractAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender); // Assign the deployer as the default admin
        _setRoleAdmin(OFFICER_ROLE, DEFAULT_ADMIN_ROLE); // Set DEFAULT_ADMIN_ROLE as the admin for OFFICER_ROLE
    }

    modifier notAlreadyApproved(uint256 _rfpId) {
        require(!approvalData[_rfpId].approvers[msg.sender], "Officer has already approved this bid");
        _;
    }

    function addOfficer(address officer) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(OFFICER_ROLE, officer);
        emit OfficerAdded(officer);
    }

    function removeOfficer(address officer) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(OFFICER_ROLE, officer);
        emit OfficerRemoved(officer);
    }

    function approveBid(uint256 _rfpId, address _vendor) public onlyRole(OFFICER_ROLE) notAlreadyApproved(_rfpId) {
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

    function rejectBid(uint256 _rfpId, address _vendor) public onlyRole(OFFICER_ROLE) notAlreadyApproved(_rfpId) {
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

    function getApprovalStatus(uint256 _rfpId) public view returns (ApprovalStatus) {
        return approvals[_rfpId].status;
    }

    function getApprovedVendor(uint256 _rfpId) public view returns (address) {
        require(approvals[_rfpId].status == ApprovalStatus.Approved, "Bid not approved");
        return approvals[_rfpId].vendor;
    }
}
