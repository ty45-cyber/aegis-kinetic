<div align="center">

# 🛡️ Aegis-Kinetic LOB
### Ultra-Low Latency Parallel Limit Order Book & Kinetic Risk Clearing Protocol

**Built for the Monad Metropolis Hackathon ($250,000 Prize Pool | 10,000 TPS Parallel EVM)**

[Architecture](./docs/architecture.md) • [Live Demo](#-quickstart-30-second-judge-flow) • [Smart Contracts](./contracts/) • [WASM Engine](./engine/)

</div>

---

## 🚀 Overview
**Aegis-Kinetic** is a production-grade, fully on-chain order book engineered to exploit Monad's parallel execution engine and sub-second finality. By combining Yul assembly bitwise scanning, lock-free SPSC ring buffers, and thermodynamic Langevin fee models, Aegis-Kinetic solves EVM state contention and achieves amortized $O(1)$ order execution.

---

## ⚡ Quickstart: 30-Second Judge Flow

Evaluate the complete system instantly via the unified Makefile:

```bash
# 1. Clone repository & install dependencies
git clone [https://github.com/aegis-kinetic/aegis-kinetic.git](https://github.com/aegis-kinetic/aegis-kinetic.git)
cd aegis-kinetic
make install

# 2. Build WASM engine, smart contracts, and client app
make build

# 3. Run full test suite (Fuzzing, Invariants, Rust Unit Tests)
make test

# 4. Launch the Next.js 30-Second Judge HUD
cd client && npm run dev