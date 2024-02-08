// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
/** 
    @title Master Government Procurement contract
    @notice This contract manages the overarching workflow between all the other contracts for the
    whole procurement process.
*/

import "./VendorRegistration.sol";
import "./RFPIssuance.sol";
import "./BidSubmission.sol";
import "./BidEvaluation.sol";
import "./ApprovalWorkflow.sol";
import "./ContractExecution.sol";

contract ProcurementMaster {
    /// @dev Contract instance intializations of the other smart contracts
    VendorRegistration public vendorRegistrationContract;
    RFPIssuance public rfpIssuanceContract;
    BidSubmission public bidSubmissionContract;
    BidEvaluation public bidEvaluationContract;
    ApprovalWorkflow public approvalWorkflowContract;
    ContractExecution public contractExecutionContract;

    /// @dev Constructor with addresses of other contracts
    constructor(
        address _vendorRegistrationAddress,
        address _rfpIssuanceAddress,
        address _bidSubmissionAddress,
        address _bidEvaluationAddress,
        address _approvalWorkflowAddress,
        address payable _contractExecutionAddress
    ) {
        vendorRegistrationContract = VendorRegistration(_vendorRegistrationAddress);
        rfpIssuanceContract = RFPIssuance(_rfpIssuanceAddress);
        bidSubmissionContract = BidSubmission(_bidSubmissionAddress);
        bidEvaluationContract = BidEvaluation(_bidEvaluationAddress);
        approvalWorkflowContract = ApprovalWorkflow(_approvalWorkflowAddress);
        contractExecutionContract = ContractExecution(_contractExecutionAddress);
    }

    /// @dev removed deploy function contract as we do not need to deploy the vendor registration contract in here as all other contracts will deployed independently

    // Function to issue a new RFP
    function createRFP(string memory _title, string memory _description, uint256 _deadline) public {
        rfpIssuanceContract.issueRFP(_title, _description, _deadline);
    }

    // Function to submit a bid to an RFP
    function submitBidToRFP(uint256 _rfpId, string memory _bidDetails) public {
        bidSubmissionContract.submitBid(_rfpId, _bidDetails);
    }

    // Function to evaluate bids for a specific RFP
    function evaluateRFPBids(uint256 _rfpId) public {
        bidEvaluationContract.evaluateBids(_rfpId);
    }

    // Function to approve a bid
    function approveBid(uint256 _rfpId, address _vendor) public {
        approvalWorkflowContract.approveBid(_rfpId, _vendor);
    }

    // Function to execute a contract after bid approval
    function executeContract(uint256 _rfpId, uint256 _totalMilestones, uint256 _milestonePaymentAmount) public {
        contractExecutionContract.formalizeContract(_rfpId, _totalMilestones, _milestonePaymentAmount);
    }

    // Function to retrieve contract details
    function getContractDetails(uint256 _rfpId) public view returns (ContractExecution.Contract memory) {
        return contractExecutionContract.getContractDetails(_rfpId);
    }

    // Function to provide an audit trail for a contract
    function auditTrail(uint256 _rfpId) public {
        // Logic to provide an audit trail for a specific contract
        // This could involve aggregating logs or events related to the contract
    }

    // Additional helper functions as needed
}
