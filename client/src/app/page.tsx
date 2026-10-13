'use client';

import { useWasmEngine } from '../hooks/useWasmEngine';
import { useMonadRPC } from '../hooks/useMonadRPC';
import OrderConsole from '../components/OrderConsole';
import WebGLMatrix from '../components/WebGLMatrix';
import StateTracePanel from '../components/StateTracePanel';
import type { StateTrace } from '../types';

export default function HUDPage() {
  const { engine, isReady: isEngineReady, error: engineError } = useWasmEngine();
  const { isConnected: isRpcConnected, traces } = useMonadRPC();
  const stateTraces: StateTrace[] = traces.map((trace) => ({
    id: trace.hash,
    txHash: trace.hash,
    slotId: trace.slot,
    latencyMs: trace.latencyMs,
    status: trace.confirmed ? 'Confirmed' : 'Pending',
    timestamp: trace.slot,
  }));

  return (
    <main className="min-h-screen bg-black text-gray-100 p-6 grid grid-cols-12 gap-6 font-mono">
      {/* Top Header Row */}
      <header className="col-span-12 flex justify-between items-end border-b border-gray-800 pb-4">
        <div>
          <h1 className="text-2xl font-bold tracking-tighter text-white">30-SECOND JUDGE</h1>
          <p className="text-xs text-gray-500 mt-1">PARALLEL EXECUTION ENVIRONMENT</p>
        </div>
        <div className="flex gap-4 text-xs">
          <div className="flex items-center gap-2">
            <span className="text-gray-500">MONAD RPC:</span>
            <span className={isRpcConnected ? 'text-emerald-500' : 'text-yellow-500'}>
              {isRpcConnected ? 'CONNECTED' : 'CONNECTING...'}
            </span>
          </div>
          <div className="flex items-center gap-2">
            <span className="text-gray-500">WASM ENGINE:</span>
            <span className={isEngineReady ? 'text-emerald-500' : 'text-red-500'}>
              {isEngineReady ? 'INJECTED' : engineError ? 'FAILED' : 'INITIALIZING...'}
            </span>
          </div>
        </div>
      </header>

      {/* Main Grid: Left Column (Visuals & Input) */}
      <div className="col-span-12 lg:col-span-8 flex flex-col gap-6">
        {/* WebGL parallel thread visualization (Zero-copy read from WASM memory) */}
        <section className="h-[400px] bg-gray-900 border border-gray-800 rounded-lg overflow-hidden relative">
          {isEngineReady ? (
            <WebGLMatrix tps={traces[0]?.tps ?? 0} />
          ) : (
            <div className="absolute inset-0 flex items-center justify-center text-gray-700">
              AWAITING WASM MEMORY BUFFER...
            </div>
          )}
        </section>

        {/* Lightning Order Entry */}
        <section>
          <OrderConsole engine={engine} isEngineReady={isEngineReady} />
        </section>
      </div>

      {/* Right Column: Real-time Slot Traces */}
      <div className="col-span-12 lg:col-span-4 flex flex-col max-h-[calc(100vh-8rem)]">
        <section className="flex-1 overflow-hidden bg-gray-900 border border-gray-800 rounded-lg flex flex-col">
          <div className="p-3 border-b border-gray-800 bg-gray-950 flex justify-between items-center">
            <h3 className="text-xs font-bold text-gray-400">SLOT ALLOCATION LOG</h3>
            <span className="text-xs text-emerald-500">{traces.length > 0 ? traces[0].tps : 0} TPS</span>
          </div>
          <div className="flex-1 overflow-y-auto">
            <StateTracePanel traces={stateTraces} />
          </div>
        </section>
      </div>
    </main>
  );
}