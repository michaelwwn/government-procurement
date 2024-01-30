// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VendorRegistration {

    struct Vendor {
        string name;
        address vendorAddress;
        bool isRegistered;
        bool isEligible;
    }

    mapping(address => Vendor) public vendors;

    event VendorRegistered(address indexed vendorAddress, string name);
    event VendorStatusChanged(address indexed vendorAddress, bool isEligible);

    // Function to register a vendor
    function registerVendor(string memory _name) public {
        require(vendors[msg.sender].vendorAddress == address(0), "Vendor already registered");
        
        vendors[msg.sender] = Vendor({
            name: _name,
            vendorAddress: msg.sender,
            isRegistered: true,
            isEligible: false // Eligibility to be determined
        });

        emit VendorRegistered(msg.sender, _name);
    }

    // Function to change the eligibility status of a vendor
    function changeVendorEligibility(address _vendorAddress, bool _isEligible) public {
        // Only eligible to be called by the contract owner or an authorized party
        require(vendors[_vendorAddress].isRegistered, "Vendor not registered");

        vendors[_vendorAddress].isEligible = _isEligible;

        emit VendorStatusChanged(_vendorAddress, _isEligible);
    }

    // Function to check if a vendor is registered
    function isVendorRegistered(address _vendorAddress) public view returns (bool) {
        return vendors[_vendorAddress].isRegistered;
    }

    // Function to check the eligibility of a vendor
    function isVendorEligible(address _vendorAddress) public view returns (bool) {
        return vendors[_vendorAddress].isEligible;
    }

    // Function to get vendor details
    function getVendorDetails(address _vendorAddress) public view returns (Vendor memory) {
        require(vendors[_vendorAddress].isRegistered, "Vendor not registered");
        return vendors[_vendorAddress];
    }
}
