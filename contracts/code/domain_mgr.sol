// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DomainManager {
    struct Domain {
        string serviceAddr;
        address owner;
    }

    // Mapping from domain name to Domain struct
    mapping(string => Domain) private domains;

    // Array to store all registered domain names
    string[] private domainNames;

    // Events
    event DomainRegistered(string indexed domainName, string serviceAddr, address indexed owner);
    event DomainUnregistered(string indexed domainName, address indexed owner);
    event ServiceAddrUpdated(string indexed domainName, string newServiceAddr);

    // Register a new domain
    function registerDomain(string memory domainName, string memory serviceAddr) public {
        require(bytes(domainName).length > 0, "Domain name cannot be empty");
        require(bytes(serviceAddr).length > 0, "Service address cannot be empty");
        require(domains[domainName].owner == address(0), "Domain is already registered");

        domains[domainName] = Domain({
            serviceAddr: serviceAddr,
            owner: msg.sender
        });

        domainNames.push(domainName);

        emit DomainRegistered(domainName, serviceAddr, msg.sender);
    }

    // Unregister a domain
    function unregisterDomain(string memory domainName) public {
        require(domains[domainName].owner == msg.sender, "Only the owner can unregister the domain");

        // Find and remove the domain from the domainNames array
        for (uint i = 0; i < domainNames.length; i++) {
            if (keccak256(bytes(domainNames[i])) == keccak256(bytes(domainName))) {
                domainNames[i] = domainNames[domainNames.length - 1];
                domainNames.pop();
                break;
            }
        }

        delete domains[domainName];

        emit DomainUnregistered(domainName, msg.sender);
    }

    // Get domain information
    function getDomain(string memory domainName) public view returns (string memory serviceAddr, address owner) {
        require(domains[domainName].owner != address(0), "Domain is not registered");

        Domain memory domain = domains[domainName];
        return (domain.serviceAddr, domain.owner);
    }

    // Transfer domain ownership
    function transferDomainOwnership(string memory domainName, address newOwner) public {
        require(domains[domainName].owner == msg.sender, "Only the owner can transfer the domain");

        domains[domainName].owner = newOwner;
    }

    // Update service address for a domain
    function updateServiceAddr(string memory domainName, string memory newServiceAddr) public {
        require(domains[domainName].owner == msg.sender, "Only the owner can update the service address");
        require(bytes(newServiceAddr).length > 0, "New service address cannot be empty");

        domains[domainName].serviceAddr = newServiceAddr;

        emit ServiceAddrUpdated(domainName, newServiceAddr);
    }

    // Get all registered domain names
    function getAllDomains() public view returns (string[] memory) {
        return domainNames;
    }
}