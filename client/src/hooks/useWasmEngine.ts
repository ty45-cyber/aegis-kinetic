'use client';

import { useState, useEffect, useRef } from 'react';
import type { WasmEngine, EngineContext } from '../types';

export const useWasmEngine = (): EngineContext => {
  const [isReady, setIsReady] = useState(false);
  const [error, setError] = useState<Error | null>(null);
  const engineRef = useRef<WasmEngine | null>(null);

  useEffect(() => {
    let mounted = true;

    const initWasm = async () => {
      if (engineRef.current) return;

      try {
        const wasmModulePath = '/wasm/aegis_engine.js';
        const wasmModule = await import(/* webpackIgnore: true */ wasmModulePath);
        await wasmModule.default();
        
        if (mounted) {
          engineRef.current = wasmModule as WasmEngine;
          setIsReady(true);
        }
      } catch (err) {
        if (mounted) {
          setError(err instanceof Error ? err : new Error('WASM Initialization failed'));
        }
      }
    };

    initWasm();

    return () => {
      mounted = false;
      // Note: WASM memory is garbage collected when the module loses all references,
      // but explicit cleanup logic for Rust-allocated pointers should go here.
    };
  }, []);

  return { isReady, engine: engineRef.current, error };
};