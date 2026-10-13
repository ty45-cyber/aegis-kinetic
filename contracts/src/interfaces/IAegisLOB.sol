// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

/// @title IAegisLOB
/// @notice Interface for the Aegis-Kinetic Parallel Limit Order Book and Clearing Engine
interface IAegisLOB {
    enum Side {
        Bid,
        Ask
    }

    enum OrderType {
        Limit,
        Market,
        PostOnly
    }

    struct Order {
        uint128 id;
        uint64 price;
        uint64 amount;
        address maker;
        uint32 nextIndex;
        uint32 prevIndex;
        uint8 slotId;
    }

    struct PriceLevel {
        uint32 head;
        uint32 tail;
        uint128 totalVolume;
    }

    struct MatchResult {
        uint128 matchedVolume;
        uint256 totalCost;
        uint256 dynamicFeePaid;
        uint32 ordersExecuted;
    }

    event OrderPlaced(
        uint128 indexed orderId,
        address indexed maker,
        Side indexed side,
        uint64 price,
        uint64 amount,
        uint8 slotId
    );

    event OrderCancelled(
        uint128 indexed orderId,
        address indexed maker,
        Side indexed side,
        uint64 price,
        uint64 remainingAmount
    );

    event OrdersMatched(
        uint128 indexed takerOrderId,
        uint128 indexed makerOrderId,
        address taker,
        address maker,
        uint64 fillPrice,
        uint64 fillAmount,
        uint256 dynamicFee
    );

    event KineticFeeUpdated(uint256 baseFeeBps, uint256 dynamicFeeBps, uint256 velocity);

    error InvalidPrice();
    error InvalidAmount();
    error OrderNotFound();
    error Unauthorized();
    error PostOnlyCrossed();
    error InsufficientEscrow();
    error SlotLockContention();

    function placeOrder(
        Side side,
        OrderType orderType,
        uint64 price,
        uint64 amount
    ) external payable returns (uint128 orderId, uint64 filledAmount);

    function cancelOrder(uint128 orderId, Side side, uint64 price) external returns (bool);

    function getBestBid() external view returns (uint64 price, uint128 volume);

    function getBestAsk() external view returns (uint64 price, uint128 volume);

    function getFeeViscosity() external view returns (uint256 baseFeeBps, uint256 dynamicFeeBps);
}