// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title VulnerableToken
 * @dev This contract intentionally contains several security vulnerabilities 
 * for educational purposes. DO NOT use in production.
 */
contract VulnerableToken {
    string public name = "VulnerableToken";
    string public symbol = "VULN";
    uint8 public decimals = 18;
    uint256 public totalSupply;
    
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    
    address public owner;
    
    constructor(uint256 initialSupply) {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        owner = msg.sender;
    }
    
    // VULNERABILITY 1: Missing validation allows zero address transfers
    function transfer(address to, uint256 amount) public returns (bool) {
        // No validation for zero address
        
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    
    // VULNERABILITY 2: No checks for sufficient balance
    function unsafeTransfer(address to, uint256 amount) public returns (bool) {
        // No check for sufficient balance can lead to underflow
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
    
    // VULNERABILITY 3: Integer overflow (less relevant in Solidity 0.8+, but still important to demonstrate)
    function approve(address spender, uint256 amount) public returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }
    
    // VULNERABILITY 4: Reentrancy vulnerability
    function withdrawAll() public {
        uint256 amount = balanceOf[msg.sender];
        // VULNERABILITY: Sends funds before updating the balance
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        
        // Balance update happens after external call
        balanceOf[msg.sender] = 0;
    }
    
    // VULNERABILITY 5: Unchecked return value
    function transferFrom(address from, address to, uint256 amount) public returns (bool) {
        if (allowance[from][msg.sender] >= amount) {
            allowance[from][msg.sender] -= amount;
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
        }
        // No else clause, no revert if allowance is insufficient
        return true; // Always returns true even if the transfer failed
    }
    
    // VULNERABILITY 6: Unprotected function with privileged operation
    function mint(address to, uint256 amount) public {
        // No access control - anyone can mint tokens
        totalSupply += amount;
        balanceOf[to] += amount;
    }
    
    // VULNERABILITY 7: Timestamp dependence
    function isLuckyDay() public view returns (bool) {
        // Using block.timestamp is vulnerable to miner manipulation
        return (block.timestamp % 7 == 0);
    }
    
    // VULNERABILITY 8: Denial of service through unbounded operation
    function airdropTokens(address[] memory recipients, uint256 amount) public {
        // No limit on the array size can cause gas limit issues
        for (uint256 i = 0; i < recipients.length; i++) {
            balanceOf[recipients[i]] += amount;
        }
        totalSupply += amount * recipients.length;
    }
} 