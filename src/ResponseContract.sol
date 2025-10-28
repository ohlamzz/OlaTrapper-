// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface ITokenFactory {
    function pauseFactory() external;
}

contract ResponseContract {
    address public immutable TOKEN_FACTORY_ADDRESS;
    address public owner;

    event ScamAlertTriggered(address indexed detector, uint256 flaggedCount, string message);

    constructor(address _tokenFactoryAddress) {
        TOKEN_FACTORY_ADDRESS = _tokenFactoryAddress;
        owner = msg.sender;
    }

    function response(uint256 flaggedCount) external {
        require(msg.sender != address(0), "Invalid caller");

        if (flaggedCount > 10) {
            emit ScamAlertTriggered(msg.sender, flaggedCount, "Potential Token Pair Spam Detected");

            // Optional: automatically pause the factory when triggered
            // ITokenFactory(TOKEN_FACTORY_ADDRESS).pauseFactory();
        }
    }
}
