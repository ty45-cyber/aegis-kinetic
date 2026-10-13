// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title KineticFeeMath
/// @notice Implements thermodynamic Langevin viscosity equations for dynamic fee adjustments
library KineticFeeMath {
    uint256 public constant WAD = 1e18;
    uint256 public constant MAX_DYNAMIC_FEE_BPS = 500; // 5.00% cap
    uint256 public constant BASE_FEE_BPS = 5;         // 0.05% base

    /// @notice Calculates dynamic viscosity fee based on price velocity dP/dt
    /// @param baseFeeBps Standard baseline fee in basis points
    /// @param priceDelta Absolute difference between current price and previous price (1e18 scaled)
    /// @param timeDelta Time elapsed in seconds (or block duration)
    /// @param lambda Scaling coefficient for market sensitivity
    /// @return dynamicFeeBps Effective calculated dynamic fee in basis points
    function calculateKineticFee(
        uint256 baseFeeBps,
        uint256 priceDelta,
        uint256 timeDelta,
        uint256 lambda
    ) internal pure returns (uint256 dynamicFeeBps) {
        if (timeDelta == 0) {
            timeDelta = 1; // Prevent division by zero on same-block execution
        }

        // Velocity = |dP / dt|
        uint256 velocity = (priceDelta * WAD) / timeDelta;

        // Dynamic Fee = BaseFee * (1 + lambda * Velocity)
        uint256 feeMultiplier = WAD + ((lambda * velocity) / WAD);
        uint256 calculatedFee = (baseFeeBps * feeMultiplier) / WAD;

        if (calculatedFee > MAX_DYNAMIC_FEE_BPS) {
            return MAX_DYNAMIC_FEE_BPS;
        }

        return calculatedFee < baseFeeBps ? baseFeeBps : calculatedFee;
    }

    /// @notice Converts fee basis points to absolute token amount
    /// @param amount Total order or execution volume
    /// @param feeBps Fee in basis points (1 bps = 0.01%)
    function calculateFeeAmount(uint256 amount, uint256 feeBps) internal pure returns (uint256) {
        return (amount * feeBps) / 10_000;
    }
}