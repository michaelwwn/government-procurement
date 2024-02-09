// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ApprovalWorkflow.sol"; // Import the ApprovalWorkflow contract

contract ContractExecution {
    ApprovalWorkflow approvalWorkflowContract; // Instance of the ApprovalWorkflow contract
    address public owner;

    struct Contract {
        uint256 rfpId;
        address payable vendor;
        bool isActive;
        uint256 totalMilestones;
        uint256 milestonesCompleted;
        uint256 milestonePaymentAmount;
    }

    mapping(uint256 => Contract) public contracts;

    event ContractCreated(uint256 indexed rfpId, address indexed vendor);
    event MilestoneCompleted(uint256 indexed rfpId, uint256 milestonesCompleted, uint256 paymentAmount);
    event ContractCompleted(uint256 indexed rfpId);
    event FundsDeposited(uint256 amount, address depositor);

    constructor(address _approvalWorkflowContractAddress) {
        approvalWorkflowContract = ApprovalWorkflow(_approvalWorkflowContractAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }

    // Function to deposit funds into the contract
    function depositFunds() public payable onlyOwner {
        emit FundsDeposited(msg.value, msg.sender);
    }

    // Function to formalize a contract
    function formalizeContract(uint256 _rfpId, uint256 _totalMilestones, uint256 _milestonePaymentAmount) public onlyOwner {
        address payable approvedVendor = payable(approvalWorkflowContract.getApprovedVendor(_rfpId));

        contracts[_rfpId] = Contract({
            rfpId: _rfpId,
            vendor: approvedVendor,
            isActive: true,
            totalMilestones: _totalMilestones,
            milestonesCompleted: 0,
            milestonePaymentAmount: _milestonePaymentAmount
        });

        emit ContractCreated(_rfpId, approvedVendor);
    }

    // Function to mark a milestone as completed and transfer funds
    function completeMilestone(uint256 _rfpId) public onlyOwner{
        Contract storage contractToUpdate = contracts[_rfpId];
        require(contractToUpdate.isActive, "Contract is not active");
        require(contractToUpdate.milestonesCompleted < contractToUpdate.totalMilestones, "All milestones already completed");
        require(address(this).balance >= contractToUpdate.milestonePaymentAmount, "Insufficient funds in contract");

        contractToUpdate.milestonesCompleted++;
        contractToUpdate.vendor.transfer(contractToUpdate.milestonePaymentAmount);

        emit MilestoneCompleted(_rfpId, contractToUpdate.milestonesCompleted, contractToUpdate.milestonePaymentAmount);

        if (contractToUpdate.milestonesCompleted == contractToUpdate.totalMilestones) {
            contractToUpdate.isActive = false;
            emit ContractCompleted(_rfpId);
        }
    }

    // Function to get contract details
    function getContractDetails(uint256 _rfpId) public view returns (Contract memory) {
        return contracts[_rfpId];
    }

    // Function to withdraw any remaining funds (for simplicity, assuming only owner can do this)
    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // Fallback function to accept Ether
    receive() external payable {}
}
