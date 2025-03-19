// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title SecureToken
 * @dev This contract demonstrates secure smart contract practices
 * by implementing proper security measures to address common vulnerabilities.
 */
contract SecureToken is ERC20, ERC20Burnable, AccessControl, ReentrancyGuard {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    // Maximum number of recipients in a batch operation to prevent DoS
    uint256 public constant MAX_BATCH_SIZE = 100;
    
    // Events for important operations
    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);
    event BatchTransfer(address indexed sender, uint256 recipientCount);
    
    constructor(uint256 initialSupply) ERC20("SecureToken", "SECR") {
        // Set up admin role
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        
        // Mint initial supply to deployer
        _mint(msg.sender, initialSupply * 10**decimals());
    }
    
    /**
     * @dev Securely transfers tokens with proper validation
     * - Zero address check
     * - Sufficient balance check (covered by OpenZeppelin's ERC20 implementation)
     */
    function transfer(address to, uint256 amount) public override returns (bool) {
        require(to != address(0), "SecureToken: transfer to the zero address");
        return super.transfer(to, amount);
    }
    
    /**
     * @dev Securely approves spender with proper validation
     * - Zero address check
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        require(spender != address(0), "SecureToken: approve to the zero address");
        return super.approve(spender, amount);
    }
    
    /**
     * @dev Securely transfers tokens from sender to recipient with proper validation
     * - Zero address checks
     * - Sufficient allowance check (covered by OpenZeppelin's ERC20 implementation)
     * - Sufficient balance check (covered by OpenZeppelin's ERC20 implementation)
     */
    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(from != address(0), "SecureToken: transfer from the zero address");
        require(to != address(0), "SecureToken: transfer to the zero address");
        return super.transferFrom(from, to, amount);
    }
    
    /**
     * @dev Securely mints new tokens with proper access control
     * - Only addresses with MINTER_ROLE can mint tokens
     * - Zero address check
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        require(to != address(0), "SecureToken: mint to the zero address");
        _mint(to, amount);
    }
    
    /**
     * @dev Allows withdrawing tokens with protection against reentrancy attacks
     * - Updates state before external calls
     * - Uses nonReentrant modifier
     */
    function withdraw(uint256 amount) public nonReentrant {
        require(amount > 0, "SecureToken: amount must be greater than zero");
        require(balanceOf(msg.sender) >= amount, "SecureToken: insufficient balance");
        
        // Update state before external call
        _burn(msg.sender, amount);
        
        // Safe external call after state changes
        (bool success, ) = msg.sender.call{value: 0}("");
        require(success, "SecureToken: external call failed");
    }
    
    /**
     * @dev Performs a secure batch transfer with protection against DoS attacks
     * - Limits array size
     * - Validates all inputs
     */
    function batchTransfer(address[] memory recipients, uint256[] memory amounts) public nonReentrant {
        require(recipients.length == amounts.length, "SecureToken: recipients and amounts length mismatch");
        require(recipients.length > 0, "SecureToken: empty recipients array");
        require(recipients.length <= MAX_BATCH_SIZE, "SecureToken: batch size exceeds maximum");
        
        uint256 totalAmount = 0;
        
        for (uint256 i = 0; i < recipients.length; i++) {
            require(recipients[i] != address(0), "SecureToken: transfer to the zero address");
            require(amounts[i] > 0, "SecureToken: amount must be greater than zero");
            totalAmount += amounts[i];
        }
        
        require(balanceOf(msg.sender) >= totalAmount, "SecureToken: insufficient balance for batch transfer");
        
        for (uint256 i = 0; i < recipients.length; i++) {
            _transfer(msg.sender, recipients[i], amounts[i]);
        }
        
        emit BatchTransfer(msg.sender, recipients.length);
    }
    
    /**
     * @dev Adds a new minter, only callable by admin
     */
    function addMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(account != address(0), "SecureToken: account is the zero address");
        grantRole(MINTER_ROLE, account);
        emit MinterAdded(account);
    }
    
    /**
     * @dev Removes a minter, only callable by admin
     */
    function removeMinter(address account) public onlyRole(DEFAULT_ADMIN_ROLE) {
        revokeRole(MINTER_ROLE, account);
        emit MinterRemoved(account);
    }
    
    /**
     * @dev Time-based function with security considerations
     * Note: Block timestamps can still be manipulated by miners within a small window,
     * so critical operations should not depend solely on timestamps.
     */
    function getTimeBasedBonus() public view returns (uint256) {
        // For demo purposes only - in practice, avoid direct dependence on block.timestamp
        // for critical financial calculations
        return (block.timestamp % 86400) / 3600; // Hours passed in the current day
    }
} 