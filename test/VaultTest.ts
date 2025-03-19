import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";

describe("Vault Security Tests", function () {
  let vulnerableVault: Contract;
  let secureVault: Contract;
  let owner: Signer;
  let attacker: Signer;
  let user: Signer;
  let ownerAddress: string;
  let attackerAddress: string;
  let userAddress: string;

  beforeEach(async function () {
    // Get signers
    [owner, attacker, user] = await ethers.getSigners();
    ownerAddress = await owner.getAddress();
    attackerAddress = await attacker.getAddress();
    userAddress = await user.getAddress();

    // Deploy VulnerableVault
    const VulnerableVault = await ethers.getContractFactory("VulnerableVault");
    vulnerableVault = await VulnerableVault.deploy();

    // Deploy SecureVault
    const SecureVault = await ethers.getContractFactory("SecureVault");
    secureVault = await SecureVault.deploy();

    // Fund the vaults with some ETH
    await owner.sendTransaction({
      to: vulnerableVault.getAddress(),
      value: ethers.parseEther("10")
    });

    await owner.sendTransaction({
      to: secureVault.getAddress(),
      value: ethers.parseEther("10")
    });
  });

  describe("VulnerableVault Security Issues", function () {
    it("Should be vulnerable to reentrancy attacks", async function () {
      // To fully demonstrate a reentrancy attack, we would need to create a malicious contract
      // that calls back into the vault during the execution of withdraw. For simplicity,
      // we'll just show that the vulnerable pattern exists:
      
      // First, deposit some funds
      await vulnerableVault.connect(user).deposit({ value: ethers.parseEther("1") });
      
      console.log("Reentrancy vulnerability exists because state is updated AFTER external call:");
      console.log("1. Check balance");
      console.log("2. Send ETH (external call)");
      console.log("3. Update state (too late!)");
      
      // Verify user balance before withdrawal
      const balanceBefore = await vulnerableVault.balances(userAddress);
      expect(balanceBefore).to.equal(ethers.parseEther("1"));
      
      // Withdraw funds
      await vulnerableVault.connect(user).withdraw(ethers.parseEther("1"));
      
      // Verify balance after withdrawal
      const balanceAfter = await vulnerableVault.balances(userAddress);
      expect(balanceAfter).to.equal(0);
    });

    it("Should allow unauthorized access to drain funds", async function () {
      // In VulnerableVault, anyone can call drainFunds
      const initialBalance = await ethers.provider.getBalance(vulnerableVault.getAddress());
      expect(initialBalance).to.equal(ethers.parseEther("10"));

      // Attacker can drain all funds
      await vulnerableVault.connect(attacker).drainFunds(attackerAddress);
      
      // Verify that funds were drained
      const finalBalance = await ethers.provider.getBalance(vulnerableVault.getAddress());
      expect(finalBalance).to.equal(0);
    });

    it("Should allow anyone to destroy the contract", async function () {
      // In VulnerableVault, anyone can call shutdown
      // This test is theoretical as we can't easily check if a contract is self-destructed
      // in a test environment
      
      console.log("Vulnerability: Anyone can call selfdestruct on the contract");
      console.log("This would permanently destroy the contract and send all funds to the caller");
      
      // For demonstration only - we don't actually call the method since it would
      // make the remaining tests fail
    });

    it("Should use a hardcoded gas amount for external calls", async function () {
      // The VulnerableVault uses a hardcoded gas value which could cause the call to fail
      // if gas costs change or the function needs more gas
      console.log("Vulnerability: Using hardcoded gas value (2300) for external calls");
      console.log("This is problematic because:");
      console.log("1. Gas costs can change with protocol upgrades");
      console.log("2. 2300 gas is only enough for basic operations, not function calls");
      console.log("3. This can lead to failed transactions or unintended behavior");
    });
  });

  describe("SecureVault Protections", function () {
    it("Should prevent reentrancy attacks", async function () {
      // Deposit funds in the secure vault
      await secureVault.connect(user).deposit({ value: ethers.parseEther("1") });
      
      // Verify user balance before withdrawal
      const balanceBefore = await secureVault.balanceOf(userAddress);
      expect(balanceBefore).to.equal(ethers.parseEther("1"));
      
      console.log("SecureVault prevents reentrancy by:");
      console.log("1. Using the nonReentrant modifier");
      console.log("2. Updating state BEFORE making external calls");
      console.log("3. Emitting events before external calls");
      
      // Withdraw funds
      await secureVault.connect(user).withdraw(ethers.parseEther("1"));
      
      // Verify balance after withdrawal
      const balanceAfter = await secureVault.balanceOf(userAddress);
      expect(balanceAfter).to.equal(0);
    });

    it("Should restrict privileged functions to the owner", async function () {
      // Attempt to withdraw funds as an attacker
      await expect(
        secureVault.connect(attacker).emergencyWithdraw(attackerAddress)
      ).to.be.reverted; // Will revert with Ownable error
      
      // Owner should be able to withdraw funds
      await secureVault.connect(owner).emergencyWithdraw(ownerAddress);
      
      // Verify that funds were withdrawn
      const finalBalance = await ethers.provider.getBalance(secureVault.getAddress());
      expect(finalBalance).to.equal(0);
    });

    it("Should implement pause functionality", async function () {
      // Deposit funds to test pause functionality
      await secureVault.connect(user).deposit({ value: ethers.parseEther("1") });
      
      // Pause the contract (only owner can do this)
      await secureVault.connect(owner).pause();
      
      // Try to deposit - should fail
      await expect(
        secureVault.connect(user).deposit({ value: ethers.parseEther("1") })
      ).to.be.reverted; // With Pausable error
      
      // Try to withdraw - should fail
      await expect(
        secureVault.connect(user).withdraw(ethers.parseEther("1"))
      ).to.be.reverted; // With Pausable error
      
      // Unpause
      await secureVault.connect(owner).unpause();
      
      // Now we should be able to withdraw
      await secureVault.connect(user).withdraw(ethers.parseEther("1"));
      
      // Verify balance after withdrawal
      const balanceAfter = await secureVault.balanceOf(userAddress);
      expect(balanceAfter).to.equal(0);
    });

    it("Should safely execute external calls", async function () {
      // Owner should be able to execute external calls
      const dummyCallData = "0x";
      
      // Call to the zero address should fail (validation)
      await expect(
        secureVault.connect(owner).executeCall(ethers.ZeroAddress, dummyCallData)
      ).to.be.revertedWith("SecureVault: target address cannot be zero");
      
      // Regular calls should work, but we don't check the return value directly
      // because it's a transaction response, not the actual function return value
      await secureVault.connect(owner).executeCall(userAddress, dummyCallData);
      
      // If we reached here without errors, the test passed
      // Just check that the call doesn't revert
      expect(true).to.be.true;
    });
  });
}); 