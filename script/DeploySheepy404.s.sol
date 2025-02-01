// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {Sheepy404} from "../src/Sheepy404.sol";

contract DeploySheepy404Script is Script {
    function setUp() public {}

    function run() external returns (Sheepy404) {
        string memory pk = vm.envString("PRIVATE_KEY");
        uint256 deployerPrivateKey = vm.parseUint(pk);
        address deployer = vm.addr(deployerPrivateKey);
        
        // Set specific chain ID for ABS testnet
        uint256 chainId = 11124;
        vm.chainId(chainId);
        
        vm.startBroadcast(deployerPrivateKey);
        
        // Deploy with minimal transaction data
        Sheepy404 sheepy = new Sheepy404();
        
        // Initialize with minimal gas usage
        sheepy.initialize(
            deployer,
            deployer,
            "SheepyToken",
            "ST",
            deployer,
            "SomethingSomethingNoGrief"
        );

        vm.stopBroadcast();
        return sheepy;
    }
}