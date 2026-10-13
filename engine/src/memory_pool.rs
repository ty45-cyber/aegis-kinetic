use serde::{Deserialize, Serialize};

/// Zero-copy order payload layout aligned for RPC transmission
#[repr(C, packed)]
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub struct PackedOrderPayload {
    pub side: u8,          // 0 = Bid, 1 = Ask
    pub order_type: u8,    // 0 = Limit, 1 = Market, 2 = PostOnly
    pub price: u64,        // Fixed-point price (e.g. 1e8)
    pub amount: u64,       // Fixed-point amount
    pub slot_id: u8,       // Target parallel state thread (0-15)
    pub nonce: u32,        // Replay protection nonce
}

impl PackedOrderPayload {
    /// Serializes struct into raw zero-copy byte vector (23 bytes total)
    pub fn to_bytes(&self) -> Vec<u8> {
        let mut bytes = Vec::with_capacity(std::mem::size_of::<Self>());
        bytes.push(self.side);
        bytes.push(self.order_type);
        bytes.extend_from_slice(&self.price.to_le_bytes());
        bytes.extend_from_slice(&self.amount.to_le_bytes());
        bytes.push(self.slot_id);
        bytes.extend_from_slice(&self.nonce.to_le_bytes());
        bytes
    }

    /// Deserializes raw byte array back into `PackedOrderPayload`
    pub fn from_bytes(bytes: &[u8]) -> Result<Self, String> {
        if bytes.len() < 23 {
            return Err("Payload buffer underflow: expected 23 bytes".to_string());
        }

        let side = bytes[0];
        let order_type = bytes[1];
        let price = u64::from_le_bytes(bytes[2..10].try_into().unwrap());
        let amount = u64::from_le_bytes(bytes[10..18].try_into().unwrap());
        let slot_id = bytes[18];
        let nonce = u32::from_le_bytes(bytes[19..23].try_into().unwrap());

        Ok(Self {
            side,
            order_type,
            price,
            amount,
            slot_id,
            nonce,
        })
    }
}