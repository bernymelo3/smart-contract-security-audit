// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title SecureVault
 * @dev This contract demonstrates secure smart contract practices for
 * implementing a vault that holds Ether.
 */
contract SecureVault is ReentrancyGuard, Ownable, Pausable {
    mapping(address => uint256) private _balances;
    
    // Events for important state changes
    event Deposited(address indexed depositor, uint256 amount);
    event Withdrawn(address indexed withdrawer, uint256 amount);
    event EmergencyWithdraw(address indexed owner, uint256 amount);
    event ExternalCallExecuted(address indexed target, bool success);
    
    constructor() Ownable(msg.sender) Pausable() {
        // Initializes the Ownable contract, setting deployer as owner
    }
    
    /**
     * @dev Allows users to deposit Ether
     * - Emits deposit event
     * - Updates state securely
     */
    receive() external payable whenNotPaused {
        _deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Explicit deposit function
     */
    function deposit() public payable whenNotPaused {
        _deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Internal function to handle deposits
     * - Uses OpenZeppelin's SafeMath via Solidity 0.8+ 
     */
    function _deposit(address depositor, uint256 amount) private {
        require(amount > 0, "SecureVault: deposit amount must be greater than zero");
        
        // Safe addition (Solidity 0.8+ has built-in overflow protection)
        _balances[depositor] += amount;
        
        emit Deposited(depositor, amount);
    }
    
    /**
     * @dev Securely allows users to withdraw their funds
     * - Uses nonReentrant modifier to prevent reentrancy attacks
     * - Updates state before external call
     * - Emits withdrawal event
     */
    function withdraw(uint256 amount) public nonReentrant whenNotPaused {
        require(amount > 0, "SecureVault: withdrawal amount must be greater than zero");
        require(_balances[msg.sender] >= amount, "SecureVault: insufficient balance");
        
        // Update state before external call to prevent reentrancy
        _balances[msg.sender] -= amount;
        
        // Emit event before external call
        emit Withdrawn(msg.sender, amount);
        
        // External call after state updates
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "SecureVault: transfer failed");
    }
    
    /**
     * @dev Gets the balance of a specific account
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }
    
    /**
     * @dev Gets the total balance of the contract
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    /**
     * @dev Emergency withdrawal function with proper access control
     * - Only owner can call this function
     * - Emits event
     */
    function emergencyWithdraw(address payable recipient) public onlyOwner {
        uint256 amount = address(this).balance;
        
        // Emit event before transfer
        emit EmergencyWithdraw(owner(), amount);
        
        // Transfer funds
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "SecureVault: emergency transfer failed");
    }
    
    /**
     * @dev Secure external call with proper access control and no hardcoded gas
     * - Only owner can execute external calls
     * - No hardcoded gas amount
     * - Uses nonReentrant to prevent reentrancy
     * - Returns call result
     */
    function executeCall(address target, bytes memory data) 
        public 
        onlyOwner 
        nonReentrant 
        returns (bool, bytes memory) 
    {
        require(target != address(0), "SecureVault: target address cannot be zero");
        
        (bool success, bytes memory returnData) = target.call(data);
        
        emit ExternalCallExecuted(target, success);
        
        return (success, returnData);
    }
    
    /**
     * @dev Pause the contract
     * - Only owner can pause
     */
    function pause() public onlyOwner {
        _pause();
    }
    
    /**
     * @dev Unpause the contract
     * - Only owner can unpause
     */
    function unpause() public onlyOwner {
        _unpause();
    }
} 