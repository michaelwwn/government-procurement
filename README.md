# Smart Contracts Implementation for Procurement Procedures (Open Tenders)

## Background
This project is a part of the MH6814 Blockchain II group project assignment. Our team has explored the feasibility of replacing the traditional procurement process used by the Singapore Government with a blockchain-based smart contract system. Our aim is to enhance transparency, efficiency, and automation in the procurement process using Ethereum blockchain technology.

## Overview
The project involves the development of several interconnected smart contracts, each handling a specific aspect of the procurement process. These contracts collectively form a comprehensive system designed to manage vendor registration, request for proposals (RFP) issuance, bid submission, bid evaluation, approval workflow, and contract execution.

## Contracts
Each contract in the system has a dedicated role:

### `VendorRegistration.sol`
Handles the registration of vendors, including storing vendor details and verifying their eligibility.

### `RFPIssuance.sol`
Manages the issuance of Requests for Proposals (RFPs), enabling the government to create and publish new RFPs with detailed requirements.

### `BidSubmission.sol`
Facilitates vendors to submit their bids in response to published RFPs, ensuring timely and secure bid submissions.

### `BidEvaluation.sol`
Automates the evaluation of submitted bids based on predefined criteria to select the most suitable vendor for the project.

### `ApprovalWorkflow.sol`
Manages the approval process post-bid evaluation, ensuring that only authorized personnel can approve or reject bids.

### `ContractExecution.sol`
Handles the formalization of the contract with the winning vendor and monitors the progress of the contract, including milestone completions.
