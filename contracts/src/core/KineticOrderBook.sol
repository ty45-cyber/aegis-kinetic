// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "../interfaces/IAegisLOB.sol";
import "../math/BitScanner.sol";

/// @title KineticOrderBook
/// @notice Lock-free Single-Producer Single-Consumer order book storage & queue management
library KineticOrderBook {
    using BitScanner for uint256;

    struct Queue {
        mapping(uint128 => IAegisLOB.Order) orders;
        mapping(uint64 => IAegisLOB.PriceLevel) levels;
        uint256[4] bitmask; // 1024-bit tick bitmap map
        uint128 nextOrderId;
    }

    /// @notice Inserts a new limit order into the queue
    function insertOrder(
        Queue storage self,
        address maker,
        uint64 price,
        uint64 amount,
        uint8 slotId
    ) internal returns (uint128 orderId) {
        unchecked {
            self.nextOrderId++;
            orderId = self.nextOrderId;
        }

        IAegisLOB.PriceLevel storage level = self.levels[price];

        IAegisLOB.Order memory newOrder = IAegisLOB.Order({
            id: orderId,
            price: price,
            amount: amount,
            maker: maker,
            nextIndex: 0,
            prevIndex: level.tail,
            slotId: slotId
        });

        self.orders[orderId] = newOrder;

        if (level.head == 0) {
            level.head = uint32(orderId);
            // Flip set bit in bitmask
            uint16 wordIdx = price / 256;
            uint8 bitIdx = uint8(price % 256);
            if (wordIdx < 4) {
                self.bitmask[wordIdx] |= (1 << bitIdx);
            }
        } else {
            self.orders[level.tail].nextIndex = uint32(orderId);
        }

        level.tail = uint32(orderId);
        level.totalVolume += amount;
    }

    /// @notice Removes an order from the queue
    function removeOrder(
        Queue storage self,
        uint128 orderId,
        uint64 price
    ) internal returns (bool) {
        IAegisLOB.Order memory order = self.orders[orderId];
        if (order.id == 0) return false;

        IAegisLOB.PriceLevel storage level = self.levels[price];

        if (order.prevIndex != 0) {
            self.orders[order.prevIndex].nextIndex = order.nextIndex;
        } else {
            level.head = order.nextIndex;
        }

        if (order.nextIndex != 0) {
            self.orders[order.nextIndex].prevIndex = order.prevIndex;
        } else {
            level.tail = order.prevIndex;
        }

        level.totalVolume -= order.amount;
        delete self.orders[orderId];

        // Clear set bit if level is now empty
        if (level.head == 0) {
            uint16 wordIdx = price / 256;
            uint8 bitIdx = uint8(price % 256);
            if (wordIdx < 4) {
                self.bitmask[wordIdx] &= ~(1 << bitIdx);
            }
        }

        return true;
    }
}