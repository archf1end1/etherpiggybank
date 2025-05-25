# PiggyBank Smart Contract

This Solidity smart contract implements a simple PiggyBank where a designated manager can add and manage members, and registered members can deposit and withdraw Ether.

## Features

* **Manager Role:** A single manager controls the addition of new members.
* **Member Registration:** Only the manager can register new members to the piggy bank.
* **Deposits:** Registered members can deposit Ether into their individual balances within the contract.
* **Withdrawals:** Registered members can withdraw Ether from their own balances, up to the amount they have deposited.
* **Individual Balances:** Each registered member maintains a separate balance.
* **Event Logging:** Important actions like deposits and withdrawals are logged as events for transparency.

## Getting Started

### Prerequisites

* **Solidity Compiler:** You'll need a Solidity compiler (e.g., `solc`) compatible with `^0.8.0`.
* **Ethereum Development Environment:** A development environment like Hardhat, Truffle, or Remix is recommended for deploying and interacting with the contract.
* **Ethereum Provider:** You'll need an Ethereum provider (e.g., MetaMask, Infura) to deploy the contract to a blockchain (local or testnet).

### Deployment

1.  **Compile the contract:**
    Save the contract code as `PiggyBank.sol`. Use your chosen development environment to compile it. For example, using Hardhat:

    ```bash
    npx hardhat compile
    ```

2.  **Deploy the contract:**
    Deploy the compiled contract to your desired Ethereum network. The address that deploys the contract will automatically become the `manager`.

    Example deployment script (e.g., `scripts/deploy.js` for Hardhat):

    ```javascript
    const hre = require("hardhat");

    async function main() {
      const PiggyBank = await hre.ethers.getContractFactory("PiggyBank");
      const piggyBank = await PiggyBank.deploy();

      await piggyBank.deployed();

      console.log("PiggyBank deployed to:", piggyBank.address);
      console.log("Manager address:", await piggyBank.manager());
    }

    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```

    Then run the deployment:

    ```bash
    npx hardhat run scripts/deploy.js --network <network_name>
    ```

3.  **Interact with the contract:**
    Once deployed, you can interact with the contract using:
    * **Hardhat console:** For local testing.
    * **Etherscan:** For interacting with deployed contracts on public networks.
    * **Web3 libraries (Ethers.js, Web3.js):** For building custom scripts or front-end applications.

## Contract Details

### State Variables

* `manager`: (`address` public) The address of the contract manager. This is the address that deployed the contract.
* `members`: (`address[]` private) An array storing the addresses of all registered members.
* `balance`: (`mapping(address => uint256)` public) A mapping that stores the Ether balance for each registered member.
* `isRegistered`: (`mapping(address => bool)` private) A mapping to quickly check if an address is a registered member.

### Events

* `Deposit(address indexed member, uint256 amount)`: Emitted when a member successfully deposits Ether.
* `Withdrawal(address indexed member, uint256 amount)`: Emitted when a member successfully withdraws Ether.

### Modifiers

* `onlyManager()`: Restricts access to functions to only the `manager` address.
* `onlyRegistered()`: Restricts access to functions to only registered members.

### Functions

* `constructor()`:
    * Sets the `manager` to the address that deploys the contract.
    * Automatically registers the `manager` as the first member.
* `addMember(address newMember)` (`public` `onlyManager`):
    * Allows the `manager` to add a new address as a registered member.
    * Requires `newMember` to be a valid, non-zero address.
    * Requires `newMember` not to be the manager.
    * Requires `newMember` not to be already registered.
* `deposit()` (`public` `payable` `onlyRegistered`):
    * Allows any registered member to deposit Ether into their balance.
    * Requires the deposited `msg.value` to be greater than 0.
    * Increments the caller's balance.
    * Emits a `Deposit` event.
* `withdraw(uint256 amount)` (`public` `onlyRegistered`):
    * Allows a registered member to withdraw a specified `amount` from their balance.
    * Requires `amount` to be greater than 0.
    * Requires the `amount` to be less than or equal to the caller's current balance.
    * Decrements the caller's balance.
    * Transfers the `amount` of Ether to the caller.
    * Emits a `Withdrawal` event.
* `getBalance(address member)` (`public` `view` `returns(uint256)`):
    * Returns the current balance of a specified `member`.

## Security Considerations

* **Manager Centralization:** The contract has a single point of control (the `manager`). If the manager's private key is compromised, the contract's member management could be affected. Consider implementing multi-signature control for critical manager functions in a production environment.
* **Re-entrancy:** The `withdraw` function uses `payable(msg.sender).transfer(amount);`, which is a safer way to send Ether compared to `call` as it limits the gas available to the recipient's fallback function, mitigating simple re-entrancy attacks.
* **No Ownership Transfer:** The contract does not include a function to transfer `manager` ownership. If the original manager address is lost, the contract's member management functions will become unusable. This might be a desired feature for a real-world application.
* **Fixed Member List:** The `members` array grows indefinitely. While `addMember` is `onlyManager`, a very large number of members could theoretically lead to high gas costs if iterating over this array were ever implemented (though it's not in the current `getBalance` function).
