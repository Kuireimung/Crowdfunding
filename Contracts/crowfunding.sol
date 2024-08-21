// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;
    uint public goal;
    uint public deadline;
    uint public amountRaised;
    mapping(address => uint) public contributions;
    bool public isClosed;

    event ContributionReceived(address contributor, uint amount);
    event GoalReached(uint totalAmountRaised);
    event FundRefunded(address contributor, uint amount);

    constructor(uint _goal, uint _duration) {
        owner = msg.sender;
        goal = _goal;
        deadline = block.timestamp + _duration;
        isClosed = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier notClosed() {
        require(!isClosed);
        _;
    }

    modifier deadlineNotPassed() {
        require(block.timestamp < deadline);
        _;
    }

    function contribute() external payable notClosed deadlineNotPassed {
        require(msg.value > 0, "Contribution must be greater than zero.");
        
        contributions[msg.sender] += msg.value;
        amountRaised += msg.value;
        
        emit ContributionReceived(msg.sender, msg.value);
        
        if (amountRaised >= goal) {
            emit GoalReached(amountRaised);
            isClosed = true;
        }
    }

    function withdraw() external onlyOwner {
        require(isClosed);
        require(amountRaised >= goal);

        uint amount = address(this).balance;
        payable(owner).transfer(amount);
    }

    function refund() external {
        require(isClosed);
        require(amountRaised < goal, "Goal was reached. No refunds.");

        uint contributedAmount = contributions[msg.sender];
        require(contributedAmount > 0, "No contributions to refund.");

        contributions[msg.sender] = 0;
        payable(msg.sender).transfer(contributedAmount);

        emit FundRefunded(msg.sender, contributedAmount);
    }

    function getContractBalance() external view returns (uint) {
        return address(this).balance;
    }
}
