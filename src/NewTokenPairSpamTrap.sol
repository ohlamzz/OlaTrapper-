	// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract NewTokenPairSpamTrap is ITrap {
    // ✅ Use your real deployed contract addresses
    address public constant RESPONSE_CONTRACT_ADDRESS = 0x56B0Dc210058397269f793F99cC60431e3368dfd;
    address public constant TOKEN_FACTORY_ADDRESS = 0xA5A2E5dfb5041513e4616862AC7adE5d9a887f75;

    constructor() {}

    function collect() external view override returns (bytes memory) {
        (bool success, bytes memory returnData) = TOKEN_FACTORY_ADDRESS.staticcall(
            abi.encodeWithSignature("pairCount()")
        );

        if (!success || returnData.length != 32) {
            return abi.encode(uint256(0));
        }

        uint256 totalPairs = abi.decode(returnData, (uint256));
        return abi.encode(totalPairs);
    }

    function shouldRespond(bytes[] calldata data) external pure override returns (bool, bytes memory) {
        if (data.length == 0 || data[0].length == 0) {
            return (false, bytes(""));
        }

        uint256 totalPairs = abi.decode(data[0], (uint256));

        bool shouldTrigger = totalPairs > 10; // Example threshold
bytes memory responseData = abi.encode(totalPairs);

        return (shouldTrigger, responseData);
    }

    function getResponseContract() external pure returns (address) {
        return RESPONSE_CONTRACT_ADDRESS;
    }

    function getResponseFunction() external pure returns (string memory) {
        return "response(uint256)";
    }

    function getResponseArguments() external pure returns (bytes memory) {
        return "";
    }
}
