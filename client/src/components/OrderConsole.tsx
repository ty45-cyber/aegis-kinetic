'use client';

import { useRef } from 'react';
import type { WasmEngine } from '../types';

interface OrderConsoleProps {
  engine: WasmEngine | null;
  isEngineReady: boolean;
}

export default function OrderConsole({ engine, isEngineReady }: OrderConsoleProps) {
  // Using refs to prevent re-renders on keystrokes for ultra-low latency entry
  const priceRef = useRef<HTMLInputElement>(null);
  const sizeRef = useRef<HTMLInputElement>(null);

  const executeOrder = (side: 'BID' | 'ASK') => {
    if (!engine || !isEngineReady) return;

    const price = parseFloat(priceRef.current?.value || '0');
    const size = parseFloat(sizeRef.current?.value || '0');

    if (price <= 0 || size <= 0) return;

    // Serialize payload to pass to WASM (simplified for UI demonstration)
    const orderPayload = new Float64Array([price, size, side === 'BID' ? 1 : 0]);
    const payloadBuffer = new Uint8Array(orderPayload.buffer);
    
    // Execute through Rust WASM bridge
    const success = engine.execute_order(payloadBuffer);
    
    if (success && priceRef.current && sizeRef.current) {
      priceRef.current.value = '';
      sizeRef.current.value = '';
    }
  };

  return (
    <div className="flex flex-col gap-4 p-4 bg-gray-900 border border-gray-800 rounded-lg font-mono">
      <div className="flex justify-between items-center mb-2">
        <h2 className="text-emerald-500 font-bold tracking-widest text-sm">EXECUTION TERMINAL</h2>
        <span className={`h-2 w-2 rounded-full ${isEngineReady ? 'bg-emerald-500' : 'bg-red-500'}`} />
      </div>

      <div className="grid grid-cols-2 gap-4">
        <div>
          <label className="block text-xs text-gray-500 mb-1">PRICE</label>
          <input
            ref={priceRef}
            type="number"
            step="0.01"
            className="w-full bg-gray-950 text-emerald-400 border border-gray-800 px-3 py-2 outline-none focus:border-emerald-500 transition-colors"
            placeholder="0.00"
          />
        </div>
        <div>
          <label className="block text-xs text-gray-500 mb-1">SIZE</label>
          <input
            ref={sizeRef}
            type="number"
            className="w-full bg-gray-950 text-emerald-400 border border-gray-800 px-3 py-2 outline-none focus:border-emerald-500 transition-colors"
            placeholder="0.00"
          />
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4 mt-2">
        <button
          onClick={() => executeOrder('BID')}
          disabled={!isEngineReady}
          className="bg-emerald-900/30 text-emerald-500 border border-emerald-800 hover:bg-emerald-800/50 py-2 font-bold transition-all disabled:opacity-50"
        >
          BUY / BID
        </button>
        <button
          onClick={() => executeOrder('ASK')}
          disabled={!isEngineReady}
          className="bg-red-900/30 text-red-500 border border-red-800 hover:bg-red-800/50 py-2 font-bold transition-all disabled:opacity-50"
        >
          SELL / ASK
        </button>
      </div>
    </div>
  );
}