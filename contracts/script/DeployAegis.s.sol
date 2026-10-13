// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Script.sol";
import "../src/core/AegisKineticLOB.sol";

contract DeployAegis is Script {
    function run() external returns (AegisKineticLOB lob) {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80) // Default Anvil key
        );

        vm.startBroadcast(deployerPrivateKey);

        lob = new AegisKineticLOB();

        console.log("=================================================");
        console.log("Aegis-Kinetic LOB Deployed Successfully!");
        console.log("Contract Address:", address(lob));
        console.log("Parallel State Slots:", lob.PARALLEL_SLOTS());
        console.log("=================================================");

        vm.stopBroadcast();
    }
}