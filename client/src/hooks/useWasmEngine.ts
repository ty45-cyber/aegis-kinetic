'use client';

import { useState, useEffect, useRef } from 'react';
import type { WasmEngine, EngineContext } from '../types';

export const useWasmEngine = (): EngineContext => {
  const [isReady, setIsReady] = useState(false);
  const [error, setError] = useState<Error null |>(null);
  const engineRef = useRef<WasmEngine null |>(null);

  useEffect(() => {
    let mounted = true;

    const initWasm = async () => {
      if (engineRef.current) return;

      try {
        // Assuming wasm-pack build with --target web
        const wasmModule = await import('../../public/engine_bg.wasm');
        const init = (await import('../../public/engine.js')).default;
        
        await init(wasmModule.default);
        
        if (mounted) {
          engineRef.current = wasmModule as unknown as WasmEngine;
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