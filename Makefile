.PHONY: help install build test clean deploy benchmark

# Default Target
help:
	@echo "Aegis-Kinetic Monad Metropolis Hackathon CLI"
	@echo "============================================="
	@echo "  make install    - Install all dependencies (contracts, engine, client)"
	@echo "  make build      - Compile smart contracts, Rust WASM engine, and Next.js app"
	@echo "  make test       - Run Foundry fuzz/invariant tests and Rust unit tests"
	@echo "  make benchmark  - Run gas snapshots and Criterion microbenchmarks"
	@echo "  make deploy     - Deploy contracts to Monad Testnet via Foundry script"
	@echo "  make clean      - Clean all build artifacts"

install:
	@echo "==> Installing contract dependencies (Foundry)..."
	cd contracts && forge install
	@echo "==> Installing engine dependencies (Cargo)..."
	cd engine && cargo check
	@echo "==> Installing client dependencies (npm)..."
	cd client && npm install

build:
	@echo "==> Building Rust WASM Engine..."
	cd engine && ./build.sh
	@echo "==> Building Next.js Client..."
	cd client && npm run build
	@echo "==> Compiling Smart Contracts..."
	cd contracts && forge build

test:
	@echo "==> Running Foundry Fuzz & Invariant Tests..."
	cd contracts && forge test --fuzz-runs 10000 -vv
	@echo "==> Running Rust Unit & Integration Tests..."
	cd engine && cargo test --workspace

benchmark:
	@echo "==> Generating Gas Snapshots..."
	cd contracts && forge snapshot
	@echo "==> Running Rust Criterion Microbenchmarks..."
	cd engine && cargo bench

deploy:
	@echo "==> Deploying AegisKineticLOB to Monad Testnet..."
	cd contracts && forge script script/DeployAegis.s.sol:DeployAegis --rpc-url monad_testnet --broadcast --verify

clean:
	@echo "==> Cleaning build artifacts..."
	cd contracts && forge clean
	cd engine && cargo clean
	rm -rf client/.next client/public/wasm