#!/usr/bin/env bash
set -euo pipefail

echo "================================================="
echo "Building Aegis-Kinetic Rust WASM Engine"
echo "================================================="

# Ensure wasm-pack is installed
if ! command -v wasm-pack &> /dev/null; then
    echo "Error: wasm-pack is not installed. Installing..."
    curl https://rustwasm.github.io/wasm-pack/installer/init.sh -sSf | sh
fi

# Set Rust flags for max vectorization and optimization
export RUSTFLAGS="-C opt-level=3 -C lto=fat"

# Compile to WebAssembly target
cd "$(dirname "$0")"
wasm-pack build --target web --release --out-dir ../client/public/wasm

echo "================================================="
echo "WASM Engine compiled successfully -> client/public/wasm"
echo "================================================="