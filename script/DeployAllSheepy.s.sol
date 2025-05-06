// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol"; // Import console.log
import "../src/Sheepy404.sol";
import "../src/Sheepy404Mirror.sol";
import "../src/SheepySale.sol";

contract DeployAllScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployerAddress = vm.addr(deployerPrivateKey); // Get deployer's address from private key
        console.log("Deployer address:", deployerAddress);
        vm.startBroadcast(deployerPrivateKey);

        Sheepy404 sheepy404 = new Sheepy404();
        Sheepy404Mirror sheepy404Mirror = new Sheepy404Mirror();
        SheepySale sheepySale = new SheepySale();

        address sheepy404Address = address(sheepy404);
        address sheepy404MirrorAddress = address(sheepy404Mirror);
        address sheepySaleAddress = address(sheepySale);

        // Call initialize functions
        sheepy404.initialize(deployerAddress, deployerAddress, sheepy404MirrorAddress, "SomethingSomethingNoGrief");
        sheepySale.initialize(deployerAddress, deployerAddress, "SomethingSomethingNoGrief");

        vm.stopBroadcast();

        // Prepare JSON content
        string memory json = string(
            abi.encodePacked(
                "{\n",
                '  "Sheepy404": "', vm.toString(sheepy404Address), '",\n',
                '  "Sheepy404Mirror": "', vm.toString(sheepy404MirrorAddress), '",\n',
                '  "SheepySale": "', vm.toString(sheepySaleAddress), '"\n',
                "}"
            )
        );

        vm.writeFile("./deployments.json", json);
    }
}

