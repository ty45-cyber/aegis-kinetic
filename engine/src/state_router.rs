use sha3::{Digest, Keccak256};

pub const PARALLEL_SLOTS: u8 = 16;

/// Computes the deterministic Monad parallel execution state slot for an EVM address.
/// Replicates Solidity logic: `uint8(keccak256(abi.encodePacked(account))) % 16`
pub fn compute_slot_id(address: &str) -> Result<u8, String> {
    let clean_addr = address.trim().trim_start_matches("0x");
    if clean_addr.len() != 40 {
        return Err("Invalid EVM address length".to_string());
    }

    let bytes = hex::decode(clean_addr).map_err(|e| format!("Hex decoding failed: {}", e))?;
    let mut hasher = Keccak256::new();
    hasher.update(&bytes);
    let hash = hasher.finalize();

    // Take the last byte or first byte modulus 16
    let slot = (hash[31] as u16 % PARALLEL_SLOTS as u16) as u8;
    Ok(slot)
}

/// Batch computes slot distribution across an array of trader addresses
pub fn compute_slot_distribution(addresses: &[String]) -> Vec<(String, u8)> {
    addresses
        .iter()
        .map(|addr| {
            let slot = compute_slot_id(addr).unwrap_or(0);
            (addr.clone(), slot)
        })
        .collect()
}