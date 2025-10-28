// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
// Ensure these imports match the exact path and name of your mock contracts
import {TokenFactoryMock} from "../src/TokenFactoryMock.sol";
import {ResponseContract} from "../src/ResponseContract.sol";

/**
 * @title DeployAll
 * @notice A Foundry script to deploy the TokenFactoryMock and the ResponseContract.
 * It links the ResponseContract address to the TokenFactoryMock and prints both Contract Addresses (CAs).
 */
contract DeployAll is Script {
    function run() public returns (address tokenFactory, address responseContractAddress) {
        // Start the broadcast transaction using the private key passed to the script.
        vm.startBroadcast();

        // 1. Deploy the TokenFactoryMock (The Target Contract)
        TokenFactoryMock factory = new TokenFactoryMock();
        tokenFactory = address(factory);
        console.log("-----------------------------------------");
        console.log("TokenFactoryMock (Target) Deployed Address:", tokenFactory);

        // 2. Deploy the ResponseContract (The Defense Contract)
        // It requires the address of the TokenFactoryMock in its constructor.
        ResponseContract response = new ResponseContract(tokenFactory);
        responseContractAddress = address(response);
        console.log("ResponseContract (Responder) Deployed Address:", responseContractAddress);
// 3. Link the two contracts
        // The factory needs to be told which ResponseContract address is authorized to call pauseFactory().
        // We use the setResponseAddress function (which is onlyOwner) and since the script sender is the
// owner of the TokenFactoryMock, this call succeeds.
        factory.setResponseAddress(responseContractAddress);
        console.log("LINKING COMPLETE: TokenFactoryMock authorized ResponseContract.");
        console.log("-----------------------------------------");

        vm.stopBroadcast();

        return (tokenFactory, responseContractAddress);
    }
}

