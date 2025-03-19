# Smart Contract Security Audit Project 🔐

[![Solidity](https://img.shields.io/badge/Solidity-%5E0.8.17-blue)](https://soliditylang.org/)
[![Hardhat](https://img.shields.io/badge/Hardhat-2.22.x-yellow)](https://hardhat.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

A comprehensive educational project demonstrating common smart contract security vulnerabilities and their fixes. This repository contains vulnerable contracts with intentional security flaws, secure counterparts, detailed audit reports, and best practices documentation.

<p align="center">
  <img src="https://i.imgur.com/cLU5A3F.png" alt="Security Concept" width="600">
</p>

## 📋 Table of Contents

- [Project Overview](#-project-overview)
- [Security Concepts Demonstrated](#-security-concepts-demonstrated)
- [Repository Structure](#-repository-structure)
- [Getting Started](#-getting-started)
- [Vulnerabilities Covered](#-vulnerabilities-covered)
- [Secure Implementation Patterns](#-secure-implementation-patterns)
- [License](#-license)
- [Disclaimer](#-disclaimer)

## 🔎 Project Overview

This project showcases the ability to:

1. **Identify vulnerabilities** in smart contracts through code inspection and testing
2. **Create secure smart contracts** that implement industry best practices
3. **Perform security audits** with detailed reports and recommendations
4. **Document security practices** for Web3 developers

The project uses Hardhat for development and testing, and includes two parallel tracks: token contracts and vault contracts, each with vulnerable and secure implementations.

## 🛡️ Security Concepts Demonstrated

| Security Concept | Implementation |
|------------------|----------------|
| **Reentrancy Prevention** | Checks-Effects-Interactions pattern, ReentrancyGuard |
| **Access Control** | Role-based access (RBAC), Function modifiers |
| **Input Validation** | Zero address checks, Balance checks |
| **Safe Operations** | Overflow/underflow protection, Safe arithmetic |
| **Gas Optimization** | Bounded operations, Efficient storage |
| **Transparency** | Event emissions, Error messages |
| **Circuit Breakers** | Pausable functionality |

## 📁 Repository Structure

```
SmartContractAudit/
├── contracts/
│   ├── VulnerableToken.sol      # Token with intentional security flaws
│   ├── SecureToken.sol          # Secure token implementation
│   ├── VulnerableVault.sol      # Vault with intentional security flaws
│   └── SecureVault.sol          # Secure vault implementation
│
├── docs/
│   ├── TokenAuditReport.md      # Security audit of token contracts
│   ├── VaultAuditReport.md      # Security audit of vault contracts
│   └── SecurityBestPractices.md # Comprehensive security guide
│
├── test/
│   ├── TokenTest.ts             # Tests demonstrating token vulnerabilities
│   └── VaultTest.ts             # Tests demonstrating vault vulnerabilities
│
└── README.md                    # Project documentation
```

## 🚀 Getting Started

### Prerequisites

- Node.js (v14 or later)
- npm (v7 or later)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/smart-contract-audit.git
   cd smart-contract-audit
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Run the tests:
   ```bash
   npx hardhat test
   ```

## 🚨 Vulnerabilities Covered

### VulnerableToken Issues

1. **Missing input validation** - Zero address transfers allowed
2. **Insufficient balance checks** - Potential underflow
3. **Reentrancy vulnerability** - External calls before state updates
4. **Unchecked return values** - Always returns success
5. **Missing access control** - Unauthorized minting
6. **Timestamp dependence** - Reliance on block.timestamp
7. **Denial of service** - Unbounded operations

### VulnerableVault Issues

1. **Reentrancy vulnerability** - State updates after external calls
2. **Missing access control** - Unauthorized fund withdrawals
3. **Missing events** - No transparency for critical operations
4. **Hardcoded gas values** - Inflexible external calls
5. **Unsafe selfdestruct** - Contract destruction without authorization
6. **Improper visibility** - Implicit function visibility

## 🔒 Secure Implementation Patterns

The secure contracts demonstrate:

- **OpenZeppelin Libraries** - Using battle-tested implementations
- **Proper Access Control** - RBAC and Ownership patterns
- **Safe External Calls** - Following Checks-Effects-Interactions pattern
- **Input Validation** - Thorough parameter checking
- **Event Emissions** - Comprehensive logging of state changes
- **Gas Efficiency** - Bounded operations and efficient storage

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

The vulnerable contracts in this repository are for **educational purposes only**. They contain intentional security flaws and should **NEVER** be used in production environments.

---

<p align="center">
  Created with ❤️ for the security of Web3
</p>
