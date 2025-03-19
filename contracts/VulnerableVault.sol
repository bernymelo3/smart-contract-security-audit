// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableVault
 * @dev This contract intentionally contains security vulnerabilities 
 * for educational purposes. DO NOT use in production.
 */
contract VulnerableVault {
    mapping(address => uint256) public balances;
    
    // VULNERABILITY: No events for important state changes
    
    // VULNERABILITY: No access control
    
    // VULNERABILITY: Receive function allows anyone to deposit
    receive() external payable {
        balances[msg.sender] += msg.value;
    }
    
    // VULNERABILITY 1: Reentrancy vulnerability
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        
        // VULNERABLE: State update after external call
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        balances[msg.sender] -= amount;
    }
    
    // VULNERABILITY 2: Unchecked math allows overflow
    function deposit() public payable {
        // VULNERABLE: Unchecked arithmetic (though Solidity 0.8+ has built-in overflow protection)
        balances[msg.sender] += msg.value;
    }
    
    // VULNERABILITY 3: No access control on privileged function
    function drainFunds(address payable recipient) public {
        // VULNERABLE: No access control, anyone can drain all funds
        uint256 amount = address(this).balance;
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Transfer failed");
    }
    
    // VULNERABILITY 4: External call with hardcoded gas
    function riskyCall(address target, bytes memory data) public {
        // VULNERABLE: Hardcoded gas amount which could lead to issues
        (bool success, ) = target.call{gas: 2300}(data);
        require(success, "Call failed");
    }
    
    // VULNERABILITY 5: Self-destruct without access control
    function shutdown() public {
        // VULNERABLE: Anyone can destroy the contract
        selfdestruct(payable(msg.sender));
    }
    
    // VULNERABILITY 6: Function visibility not explicitly declared
    function getContractBalance() view returns (uint256) {
        return address(this).balance;
    }
} 