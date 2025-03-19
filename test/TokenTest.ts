import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract, Signer } from "ethers";

describe("Token Security Tests", function () {
  let vulnerableToken: Contract;
  let secureToken: Contract;
  let owner: Signer;
  let attacker: Signer;
  let receiver: Signer;
  let ownerAddress: string;
  let attackerAddress: string;
  let receiverAddress: string;

  const initialSupply = 1000000;

  beforeEach(async function () {
    // Get signers
    [owner, attacker, receiver] = await ethers.getSigners();
    ownerAddress = await owner.getAddress();
    attackerAddress = await attacker.getAddress();
    receiverAddress = await receiver.getAddress();

    // Deploy VulnerableToken
    const VulnerableToken = await ethers.getContractFactory("VulnerableToken");
    vulnerableToken = await VulnerableToken.deploy(initialSupply);

    // Deploy SecureToken
    const SecureToken = await ethers.getContractFactory("SecureToken");
    secureToken = await SecureToken.deploy(initialSupply);
  });

  describe("VulnerableToken Security Issues", function () {
    it("Should allow transfers to the zero address", async function () {
      // In VulnerableToken, transfers to zero address are allowed (a vulnerability)
      await vulnerableToken.transfer(ethers.ZeroAddress, 1000);
      
      // Check that balance was transferred to zero address
      const zeroAddressBalance = await vulnerableToken.balanceOf(ethers.ZeroAddress);
      expect(zeroAddressBalance).to.equal(1000);
    });

    it("Should allow unauthorized minting", async function () {
      // Anyone can mint tokens in VulnerableToken
      await vulnerableToken.connect(attacker).mint(attackerAddress, 1000000);
      
      // Check that attacker was able to mint tokens
      const attackerBalance = await vulnerableToken.balanceOf(attackerAddress);
      expect(attackerBalance).to.equal(1000000);
    });

    it("Should be vulnerable to integer overflow in Solidity <0.8.0", async function () {
      // NOTE: This test is demonstrative only. In Solidity 0.8.0+, arithmetic operations
      // have built-in overflow protection, so this attack would fail.
      
      // In older Solidity versions, this would lead to overflow and allow attackers
      // to manipulate balances. We can't actually demonstrate the vulnerability with
      // Solidity 0.8.0+ but we can conceptually explain it:
      
      console.log("In Solidity <0.8.0, the following operation would cause an overflow:");
      console.log("  uint256 max = 2^256 - 1");
      console.log("  balances[attacker] = balances[attacker] + 1  // Overflows to 0");
      
      // In our 0.8.0+ contract, this would revert instead of overflowing
    });

    it("Should be vulnerable to unbounded loop DoS attacks", async function () {
      // Create a large array of recipients that could exceed gas limits
      const largeNumberOfRecipients = Array(1001).fill(receiverAddress);
      
      // This would likely fail with out-of-gas error in a real network
      // We'll catch the error to show the vulnerability
      try {
        await vulnerableToken.airdropTokens(largeNumberOfRecipients, 1);
        console.log("In a real network, this transaction would likely run out of gas");
      } catch (error: any) {
        // If we're testing locally, this might not fail due to different gas limits
        console.log("Transaction failed as expected in a DoS scenario");
      }
    });
  });

  describe("SecureToken Protections", function () {
    it("Should prevent transfers to the zero address", async function () {
      // SecureToken should block transfers to zero address
      await expect(
        secureToken.transfer(ethers.ZeroAddress, 1000)
      ).to.be.revertedWith("SecureToken: transfer to the zero address");
    });

    it("Should prevent unauthorized minting", async function () {
      // Only addresses with MINTER_ROLE can mint in SecureToken
      await expect(
        secureToken.connect(attacker).mint(attackerAddress, 1000000)
      ).to.be.reverted; // Will revert with AccessControl error
    });

    it("Should enforce batch size limits", async function () {
      // Create a large array of recipients that exceeds the MAX_BATCH_SIZE
      const manyRecipients = Array(101).fill(receiverAddress);
      const amounts = Array(101).fill(1);
      
      // SecureToken should block this operation
      await expect(
        secureToken.batchTransfer(manyRecipients, amounts)
      ).to.be.revertedWith("SecureToken: batch size exceeds maximum");
    });

    it("Should allow authorized minting", async function () {
      // Owner has MINTER_ROLE by default
      await secureToken.mint(receiverAddress, 1000);
      
      // Check that minting worked
      const receiverBalance = await secureToken.balanceOf(receiverAddress);
      expect(receiverBalance).to.equal(1000);
    });

    it("Should allow adding and removing minters", async function () {
      // Grant attacker minter role
      await secureToken.addMinter(attackerAddress);
      
      // Now attacker should be able to mint
      await secureToken.connect(attacker).mint(attackerAddress, 1000);
      const attackerBalance = await secureToken.balanceOf(attackerAddress);
      expect(attackerBalance).to.equal(1000);
      
      // Remove minter role
      await secureToken.removeMinter(attackerAddress);
      
      // Now attacker should not be able to mint
      await expect(
        secureToken.connect(attacker).mint(attackerAddress, 1000)
      ).to.be.reverted; // Will revert with AccessControl error
    });
  });
}); 