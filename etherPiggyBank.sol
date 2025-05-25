//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PiggyBank {

    address public manager;
    address[] members;
    mapping(address => uint256) public balance;
    mapping(address => bool) isRegistered;

    event Deposit(address indexed member, uint256 amount);
    event Withdrawal(address indexed member,uint256 amount);


    constructor() {
        manager = msg.sender;
        members.push(manager);
        isRegistered[manager] = true;
    }

    modifier onlyManager() {
        require(msg.sender == manager, "only manager can call this function");
        _;
    }

    modifier onlyRegistered() {
        require(isRegistered[msg.sender], "only registered members can call this function");
        _;
    }
    
    function addMember(address newMember) public onlyManager {
        require(newMember != address(0), "Invalid member address");
        require(newMember != manager, "Manager is already a member");
        require(!isRegistered[newMember], "Member is already registered");
        isRegistered[newMember] = true;
        members.push(newMember);
    }
    
    function deposit() public payable onlyRegistered {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balance[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) public onlyRegistered {
        require(amount > 0, "Withdrawal amount must be greater than 0");
        require(amount <= balance[msg.sender], "Insufficient funds");
        balance[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function getBalance(address member) public view returns(uint256) {
        return balance
    }

}