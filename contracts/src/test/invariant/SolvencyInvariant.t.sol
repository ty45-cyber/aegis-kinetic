// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../../src/core/AegisKineticLOB.sol";

contract SolvencyInvariantTest is Test {
    AegisKineticLOB internal lob;

    function setUp() public {
        lob = new AegisKineticLOB();
    }

    /// @dev Invariant check: Contract ETH balance must always match or exceed tracked total escrow volume
    function invariant_SolvencyEquilibrium() public view {
        assertGe(
            address(lob).balance,
            lob.totalEscrowedVolume(),
            "Solvency Failure: Contract balance is less than total escrowed volume"
        );
    }
}