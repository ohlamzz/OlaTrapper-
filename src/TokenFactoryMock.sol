// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TokenFactoryMock {
    uint256 public pairCount;
    bool public paused = false;
    address public owner;
    // New variable to store the authorized Response Contract address
    address public responseContract;

    event TokenPairCreated(address indexed tokenA, address indexed tokenB, uint256 indexed pairId);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function createTokenPair(address tokenA, address tokenB) external {
        require(!paused, "Factory is paused");
        pairCount += 1;
        emit TokenPairCreated(tokenA, tokenB, pairCount);
    }

    /// @notice Only the owner or the authorized ResponseContract can pause the factory.
    function pauseFactory() external {
        require(msg.sender == owner || msg.sender == responseContract, "Not authorized to pause");
        paused = true;
    }

    /// @notice Allows the owner to set the address of the ResponseContract that is authorized to call pauseFactory.
    /// This is crucial for linking the trap response to the factory defense.
    function setResponseAddress(address _responseContract) external onlyOwner {
        responseContract = _responseContract;
    }
}
