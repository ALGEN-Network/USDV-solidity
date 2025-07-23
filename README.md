# USDV Hardhat Project

This Hardhat project contains the smart contracts for the USDV token system, deployed across L1 and L2 chains using an upgradeable architecture. The project includes two main contracts:

## 🧾 Contracts

### `USDVUpgradeable.sol`
This contract is designed for deployment on **Layer 1 (L1)** networks such as Algen L1, Ethereum. It implements the core ERC20 logic along with advanced features:

- **Permit (EIP-2612):** Enables gasless approvals via off-chain signatures.
- **Whitelist/Blacklist Mechanism:** Allows role-based access control to restrict or permit transfers from specific addresses.
- **Gasless Support:** Enables relayers or privileged actors to sponsor transaction gas fees.

### `USDVUpgradeableV2.sol`
This contract is tailored for **Layer 2 (L2)** deployments (e.g., Algen L2, MesherX) and extends the L1 logic with additional L2 compatibility:

- **Support for receiving bridged tokens from L1**
- **Permit (EIP-2612) support**
- **Whitelist/Blacklist enforcement**
- **Gasless transactions on L2**
- **Integration with L2 side of StandardBridge**

## 🔧 Key Features

- ✅ **Upgradeable architecture** using OpenZeppelin’s proxy pattern
- 🔐 **Access control** for whitelist/blacklist enforcement
- 🪙 **Permit-enabled transfers** for meta-transactions
- 🌉 **Cross-chain bridge support** (L1 ↔ L2)
- ⛽ **Gasless interactions** to improve user experience

## 🛠 Development

This project uses Hardhat for smart contract development and testing.

```bash
# Install dependencies
npm install

# Compile contracts
npx hardhat compile

# Run tests
npx hardhat test
