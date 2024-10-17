// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowWithTimeout {
    address public buyer;
    address payable public seller;
    address public arbitrator;
    uint public escrowAmount;
    bool public isDelivered;
    uint public deliveryDeadline; // Timestamp for when delivery must be confirmed
    
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED, DISPUTED }
    State public state;
    State public currentState;
    event StateChanged(State newState);
    constructor(address payable _seller, address _arbitrator, uint _deliveryTime) {
        buyer = msg.sender;
        seller = _seller;
        arbitrator = _arbitrator;
        deliveryDeadline = block.timestamp + _deliveryTime;
        state = State.AWAITING_PAYMENT;
    }

    // Buyer deposits funds into escrow
    function deposit() external payable {
        require(state == State.AWAITING_PAYMENT, "Already paid");
        require(msg.sender == buyer, "Only buyer can deposit");
        require(msg.value > 0, "Deposit must be greater than 0");
        escrowAmount = msg.value;
        state = State.AWAITING_DELIVERY;
    }

    // Buyer confirms delivery of the product
    function confirmDelivery() external {
        require(msg.sender == buyer, "Only buyer can confirm delivery");
        require(state == State.AWAITING_DELIVERY, "Cannot confirm yet");
        require(block.timestamp <= deliveryDeadline, "Confirmation period expired");
        
        isDelivered = true;
        state = State.COMPLETE;
        releaseFunds();
    }

    // Seller can withdraw funds when the product is confirmed delivered
    function releaseFunds() internal {
        require(isDelivered, "Product not delivered");
        seller.transfer(escrowAmount);
        state = State.AWAITING_PAYMENT;
    }

    // Buyer or seller can trigger a dispute
    function dispute() external {
        require(msg.sender == buyer || msg.sender == seller, "Only involved parties can dispute");
        require(state == State.AWAITING_DELIVERY, "Cannot dispute");
        
        state = State.DISPUTED;
    }

    // Arbitrator resolves the dispute
    function resolveDispute(bool _releaseFundsToSeller) external {
        require(msg.sender == arbitrator, "Only arbitrator can resolve disputes");
        require(state == State.DISPUTED, "No dispute to resolve");

        if (_releaseFundsToSeller) {
            seller.transfer(escrowAmount);
        } else {
            payable(buyer).transfer(escrowAmount);
        }
        state = State.COMPLETE;
    }
    
    // If the buyer does not confirm delivery within the delivery time, the seller can withdraw funds
    function autoReleaseFunds() external {
        require(msg.sender == seller, "Only seller can call this");
        require(state == State.AWAITING_DELIVERY, "Funds already handled");
        require(block.timestamp > deliveryDeadline, "Cannot release funds before deadline");
        
        seller.transfer(escrowAmount);
        state = State.COMPLETE;
    }

    // Refund the buyer if the delivery is not made and time hasn't expired
    function refundBuyer() external {
        require(msg.sender == buyer, "Only buyer can request refund");
        require(state == State.AWAITING_DELIVERY, "No funds to refund");
        require(block.timestamp <= deliveryDeadline, "Confirmation period expired, cannot refund");
        
        state = State.REFUNDED;
        payable(buyer).transfer(escrowAmount);
    }
}
