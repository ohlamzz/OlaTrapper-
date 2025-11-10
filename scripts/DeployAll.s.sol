// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TokenFactoryMock} from "../src/TokenFactoryMock.sol";
import {ResponseContract} from "../src/ResponseContract.sol";

contract DeployAll is Script {
    function run() public returns (address tokenFactory, address responseContractAddress) {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerKey);

        // Deploy TokenFactoryMock
        TokenFactoryMock factory = new TokenFactoryMock();
        tokenFactory = address(factory);
        console.log("TokenFactoryMock deployed at:", tokenFactory);

address droseraExecutor = 0xeB921882E74e8F0dda3a71AEE3497AF0b3Ec8D63;
        // Deploy ResponseContract with the TokenFactoryMock address
        ResponseContract response = new ResponseContract(droseraExecutor,tokenFactory);
        responseContractAddress = address(response);
        console.log("ResponseContract deployed at:", responseContractAddress);

        // Link ResponseContract to TokenFactoryMock so it can pause the factory
        factory.setResponseAddress(responseContractAddress);
        console.log("Linked: TokenFactoryMock authorized ResponseContract");

        vm.stopBroadcast();
        return (tokenFactory, responseContractAddress);
    }
}

