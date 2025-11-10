// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenFactory {
    function pauseFactory() external;
}

contract ResponseContract {
    address public owner;
    address public droseraExecutor;
    ITokenFactory public factory;

    event ScamAlertTriggered(address indexed detector, uint256 flaggedCount, string message);

    modifier onlyAuthorized() {
        require(msg.sender == owner || msg.sender == droseraExecutor, "not authorized");
        _;
    }

    constructor(address _droseraExecutor, address _factory) {
        owner = msg.sender;
        droseraExecutor = _droseraExecutor;
        factory = ITokenFactory(_factory);
    }

    function setDroseraExecutor(address a) external {
        require(msg.sender == owner, "only owner");
        droseraExecutor = a;
    }

    function response(uint256 flaggedCount) external onlyAuthorized {
        if (flaggedCount > 0) {
            emit ScamAlertTriggered(msg.sender, flaggedCount, "Potential Token Pair Spam Detected");
            factory.pauseFactory(); // optional safety action
        }
    }
}
