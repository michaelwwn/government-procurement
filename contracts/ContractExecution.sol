// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ApprovalWorkflow.sol"; // Import the ApprovalWorkflow contract

contract ContractExecution {
    ApprovalWorkflow approvalWorkflowContract; // Instance of the ApprovalWorkflow contract

    struct Contract {
        uint256 rfpId;
        address vendor;
        bool isActive;
        uint256 totalMilestones;
        uint256 milestonesCompleted;
    }

    mapping(uint256 => Contract) public contracts;

    event ContractCreated(uint256 indexed rfpId, address indexed vendor);
    event MilestoneCompleted(uint256 indexed rfpId, uint256 milestonesCompleted);
    event ContractCompleted(uint256 indexed rfpId);

    constructor(address _approvalWorkflowContractAddress) {
        approvalWorkflowContract = ApprovalWorkflow(_approvalWorkflowContractAddress);
    }

    // Function to formalize a contract
    function formalizeContract(uint256 _rfpId, uint256 _totalMilestones) public {
        require(approvalWorkflowContract.getApprovalStatus(_rfpId) == ApprovalWorkflow.ApprovalStatus.Approved, "Bid not approved");

        contracts[_rfpId] = Contract({
            rfpId: _rfpId,
            vendor: approvalWorkflowContract.approvals(_rfpId).vendor,
            isActive: true,
            totalMilestones: _totalMilestones,
            milestonesCompleted: 0
        });

        emit ContractCreated(_rfpId, contracts[_rfpId].vendor);
    }

    // Function to mark a milestone as completed
    function completeMilestone(uint256 _rfpId) public {
        Contract storage contractToUpdate = contracts[_rfpId];
        require(contractToUpdate.isActive, "Contract is not active");
        require(contractToUpdate.milestonesCompleted < contractToUpdate.totalMilestones, "All milestones already completed");

        contractToUpdate.milestonesCompleted++;

        emit MilestoneCompleted(_rfpId, contractToUpdate.milestonesCompleted);

        if (contractToUpdate.milestonesCompleted == contractToUpdate.totalMilestones) {
            contractToUpdate.isActive = false;
            emit ContractCompleted(_rfpId);
        }
    }

    // Function to get contract details
    function getContractDetails(uint256 _rfpId) public view returns (Contract memory) {
        return contracts[_rfpId];
    }
}
