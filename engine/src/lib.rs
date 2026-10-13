use wasm_bindgen::prelude::*;

pub mod kinetic_model;
pub mod memory_pool;
pub mod state_router;

/// Initialize panic hook for web developer tools console logging
#[wasm_bindgen(start)]
pub fn init_panic_hook() {
    console_error_panic_hook::set_once();
}

/// WASM export: Calculates dynamic kinetic viscosity fee (in BPS)
#[wasm_bindgen]
pub fn calculate_kinetic_fee(
    base_fee_bps: u32,
    price_delta: f64,
    time_delta_seconds: f64,
    lambda_sensitivity: f64,
) -> u32 {
    kinetic_model::calculate_kinetic_fee_bps(base_fee_bps, price_delta, time_delta_seconds, lambda_sensitivity)
}

/// WASM export: Resolves target Monad parallel state slot for an EVM address
#[wasm_bindgen]
pub fn compute_slot_id(address: &str) -> Result<u8, JsValue> {
    state_router::compute_slot_id(address).map_err(|e| JsValue::from_str(&e))
}

/// WASM export: Serializes order arguments to zero-copy binary payload
#[wasm_bindgen]
pub fn serialize_order_payload(
    side: u8,
    order_type: u8,
    price: u64,
    amount: u64,
    slot_id: u8,
    nonce: u32,
) -> Result<js_sys::Uint8Array, JsValue> {
    let payload = memory_pool::PackedOrderPayload {
        side,
        order_type,
        price,
        amount,
        slot_id,
        nonce,
    };
    let bytes = payload.to_bytes();
    Ok(js_sys::Uint8Array::from(bytes.as_slice()))
}

/// WASM export: Simulates Langevin kinetic state step and returns JSON metrics
#[wasm_bindgen]
pub fn simulate_langevin_step(
    current_price: f64,
    equilibrium_price: f64,
    k_stiffness: f64,
    gamma_damping: f64,
    dt: f64,
    stochastic_noise: f64,
    lambda_sensitivity: f64,
) -> Result<JsValue, JsValue> {
    let metrics = kinetic_model::step_langevin_kinetics(
        current_price,
        equilibrium_price,
        k_stiffness,
        gamma_damping,
        dt,
        stochastic_noise,
        lambda_sensitivity,
    );
    serde_wasm_bindgen::to_value(&metrics).map_err(|e| JsValue::from_str(&e.to_string()))
}