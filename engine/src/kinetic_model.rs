use serde::{Deserialize, Serialize};

pub const WAD: f64 = 1e18;
pub const BASE_FEE_BPS: u32 = 5;       // 0.05%
pub const MAX_DYNAMIC_FEE_BPS: u32 = 500; // 5.00% cap

/// Thermodynamic state metrics resulting from Langevin velocity simulation
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct KineticStateMetrics {
    pub current_price: f64,
    pub equilibrium_price: f64,
    pub potential_energy: f64,
    pub kinetic_viscosity: f64,
    pub dynamic_fee_bps: u32,
    pub lvr_mitigation_score: f64,
}

/// Computes dynamic kinetic viscosity fee based on Langevin price velocity: dP/dt
pub fn calculate_kinetic_fee_bps(
    base_fee_bps: u32,
    price_delta: f64,
    time_delta_seconds: f64,
    lambda_sensitivity: f64,
) -> u32 {
    let dt = if time_delta_seconds <= 0.0 { 1.0 } else { time_delta_seconds };
    
    // Instantaneous velocity: |dP / dt|
    let velocity = (price_delta.abs()) / dt;
    
    // Dynamic multiplier: 1 + lambda * velocity
    let multiplier = 1.0 + (lambda_sensitivity * velocity);
    let calculated_fee = (base_fee_bps as f64) * multiplier;

    if calculated_fee > (MAX_DYNAMIC_FEE_BPS as f64) {
        MAX_DYNAMIC_FEE_BPS
    } else if calculated_fee < (base_fee_bps as f64) {
        base_fee_bps
    } else {
        calculated_fee.round() as u32
    }
}

/// Evaluates potential energy well V(x) = 0.5 * k * (x - P_0)^2
pub fn calculate_potential_energy(current_price: f64, equilibrium_price: f64, k_stiffness: f64) -> f64 {
    let dev = current_price - equilibrium_price;
    0.5 * k_stiffness * dev * dev
}

/// Euler-Maruyama step solver for Langevin price dynamics:
/// m*d2x/dt2 + gamma*dx/dt + grad(V(x)) = eta(t)
pub fn step_langevin_kinetics(
    current_price: f64,
    equilibrium_price: f64,
    k_stiffness: f64,
    gamma_damping: f64,
    dt: f64,
    stochastic_noise: f64,
    lambda_sensitivity: f64,
) -> KineticStateMetrics {
    let dev = current_price - equilibrium_price;
    let damping_force = -gamma_damping * dev;
    let spring_force = -k_stiffness * dev;
    
    let total_force = damping_force + spring_force + stochastic_noise;
    let next_price = (current_price + total_force * dt).max(0.0001);
    
    let price_delta = (next_price - current_price).abs();
    let dynamic_fee = calculate_kinetic_fee_bps(BASE_FEE_BPS, price_delta, dt, lambda_sensitivity);
    let pe = calculate_potential_energy(next_price, equilibrium_price, k_stiffness);
    
    // LVR Protection Score = viscous fee dampening / unhedged volatility ratio
    let lvr_score = (dynamic_fee as f64 / BASE_FEE_BPS as f64).min(10.0);

    KineticStateMetrics {
        current_price: next_price,
        equilibrium_price,
        potential_energy: pe,
        kinetic_viscosity: gamma_damping,
        dynamic_fee_bps: dynamic_fee,
        lvr_mitigation_score: lvr_score,
    }
}