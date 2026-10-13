#[cfg(test)]
mod tests {
    use aegis_engine::kinetic_model::{calculate_kinetic_fee_bps, calculate_potential_energy};
    use aegis_engine::memory_pool::PackedOrderPayload;
    use aegis_engine::state_router::compute_slot_id;

    #[test]
    fn test_kinetic_fee_bounds() {
        // Base fee when velocity is zero
        let fee_zero = calculate_kinetic_fee_bps(5, 0.0, 1.0, 2.0);
        assert_eq!(fee_zero, 5);

        // Max dynamic fee cap under extreme volatility
        let fee_extreme = calculate_kinetic_fee_bps(5, 1000.0, 0.001, 10.0);
        assert_eq!(fee_extreme, 500);
    }

    #[test]
    fn test_potential_energy_well() {
        let pe = calculate_potential_energy(105.0, 100.0, 2.0);
        // V(x) = 0.5 * 2.0 * (105 - 100)^2 = 25.0
        assert_eq!(pe, 25.0);
    }

    #[test]
    fn test_slot_router_deterministic() {
        let addr = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";
        let slot = compute_slot_id(addr).expect("Valid EVM address");
        assert!(slot < 16, "Slot must be within 0..15 range");
    }

    #[test]
    fn test_zero_copy_payload_roundtrip() {
        let original = PackedOrderPayload {
            side: 0,
            order_type: 1,
            price: 1500000000,
            amount: 50000000,
            slot_id: 7,
            nonce: 1024,
        };

        let bytes = original.to_bytes();
        assert_eq!(bytes.len(), 23);

        let deserialized = PackedOrderPayload::from_bytes(&bytes).unwrap();
        assert_eq!(deserialized.side, original.side);
        assert_eq!(deserialized.price, original.price);
        assert_eq!(deserialized.slot_id, original.slot_id);
    }
}