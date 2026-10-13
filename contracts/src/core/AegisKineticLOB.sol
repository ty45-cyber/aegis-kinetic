// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../interfaces/IAegisLOB.sol";
import "../math/BitScanner.sol";
import "../math/KineticFeeMath.sol";
import "./KineticOrderBook.sol";

/// @title AegisKineticLOB
/// @notice Core Parallel State Router and Order Book Clearing Entry Point for Monad EVM
contract AegisKineticLOB is IAegisLOB {
    using KineticOrderBook for KineticOrderBook.Queue;
    using BitScanner for uint256[4];

    uint8 public constant PARALLEL_SLOTS = 16;
    uint256 public constant LAMBDA_SENSITIVITY = 2e18; // Fixed-point sensitivity

    // State isolation across 16 parallel state slots to eliminate Monad OCC collisions
    mapping(uint8 => KineticOrderBook.Queue) private bidSlots;
    mapping(uint8 => KineticOrderBook.Queue) private askSlots;

    uint256 public totalEscrowedVolume;
    uint64 public lastTradedPrice;
    uint256 public lastTradeTimestamp;
    address public owner;

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    constructor() {
        owner = msg.sender;
        lastTradeTimestamp = block.timestamp;
        lastTradedPrice = 1000; // Baseline init price
    }

    /// @notice Deterministically computes parallel state slot based on maker address
    function getSlotId(address account) public pure returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(account))) % PARALLEL_SLOTS);
    }

    /// @notice Places a limit or market order on the parallel state router
    function placeOrder(
        Side side,
        OrderType orderType,
        uint64 price,
        uint64 amount
    ) external payable override returns (uint128 orderId, uint64 filledAmount) {
        if (amount == 0) revert InvalidAmount();
        if (price == 0 && orderType != OrderType.Market) revert InvalidPrice();

        uint8 slotId = getSlotId(msg.sender);
        uint256 requiredEscrow = uint256(price) * amount;

        if (side == Side.Bid) {
            if (msg.value < requiredEscrow) revert InsufficientEscrow();
            totalEscrowedVolume += msg.value;
        }

        if (side == Side.Bid) {
            orderId = bidSlots[slotId].insertOrder(msg.sender, price, amount, slotId);
        } else {
            orderId = askSlots[slotId].insertOrder(msg.sender, price, amount, slotId);
        }

        emit OrderPlaced(orderId, msg.sender, side, price, amount, slotId);

        // Calculate kinetic dynamic fee based on price velocity
        uint256 priceDelta = price > lastTradedPrice ? price - lastTradedPrice : lastTradedPrice - price;
        uint256 timeDelta = block.timestamp - lastTradeTimestamp;
        
        uint256 currentDynamicFee = KineticFeeMath.calculateKineticFee(
            KineticFeeMath.BASE_FEE_BPS,
            priceDelta * 1e18,
            timeDelta,
            LAMBDA_SENSITIVITY
        );

        lastTradedPrice = price;
        lastTradeTimestamp = block.timestamp;

        emit KineticFeeUpdated(KineticFeeMath.BASE_FEE_BPS, currentDynamicFee, priceDelta);
        return (orderId, 0);
    }

    /// @notice Cancels an existing order
    function cancelOrder(uint128 orderId, Side side, uint64 price) external override returns (bool) {
        uint8 slotId = getSlotId(msg.sender);
        bool success;

        if (side == Side.Bid) {
            success = bidSlots[slotId].removeOrder(orderId, price);
        } else {
            success = askSlots[slotId].removeOrder(orderId, price);
        }

        if (!success) revert OrderNotFound();

        emit OrderCancelled(orderId, msg.sender, side, price, 0);
        return true;
    }

    /// @notice Returns highest bid tick across state slots
    function getBestBid() external view override returns (uint64 price, uint128 volume) {
        uint16 bestTick = 0;
        for (uint8 i = 0; i < PARALLEL_SLOTS; i++) {
            uint16 tick = bidSlots[i].bitmask.scanHighestActiveTick();
            if (tick > bestTick && tick != 65535) {
                bestTick = tick;
            }
        }
        return (uint64(bestTick), 0);
    }

    /// @notice Returns lowest ask tick across state slots
    function getBestAsk() external view override returns (uint64 price, uint128 volume) {
        uint16 bestTick = 65535;
        for (uint8 i = 0; i < PARALLEL_SLOTS; i++) {
            uint16 tick = askSlots[i].bitmask.scanLowestActiveTick();
            if (tick < bestTick) {
                bestTick = tick;
            }
        }
        return (bestTick == 65535 ? 0 : uint64(bestTick), 0);
    }

    /// @notice Current dynamic viscosity fee breakdown
    function getFeeViscosity() external view override returns (uint256 baseFeeBps, uint256 dynamicFeeBps) {
        return (KineticFeeMath.BASE_FEE_BPS, KineticFeeMath.BASE_FEE_BPS);
    }

    receive() external payable {
        totalEscrowedVolume += msg.value;
    }
}