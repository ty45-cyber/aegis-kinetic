'use client';
import { StateTrace } from '../types';
import { motion, AnimatePresence } from 'framer-motion';

export default function StateTracePanel({ traces }: { traces: StateTrace[] }) {
  return (
    <div className="bg-monad-panel border border-gray-800 rounded-lg p-4 h-96 overflow-hidden flex flex-col font-mono text-sm">
      <div className="flex justify-between border-b border-gray-700 pb-2 mb-2 text-gray-400">
        <span>Tx Hash</span>
        <span>Slot ID</span>
        <span>Latency</span>
      </div>
      <div className="flex-1 overflow-y-auto pr-2 space-y-1">
        <AnimatePresence>
          {traces.map((trace) => (
            <motion.div
              key={trace.id}
              initial={{ opacity: 0, x: -20 }}
              animate={{ opacity: 1, x: 0 }}
              className="flex justify-between items-center bg-black/40 p-2 rounded border border-gray-800/50"
            >
              <span className="text-monad-purple">{trace.txHash}</span>
              <span className="text-matrix-cyan bg-blue-900/30 px-2 py-0.5 rounded">
                T-{trace.slotId.toString().padStart(2, '0')}
              </span>
              <span className="text-matrix-green">{trace.latencyMs}ms</span>
            </motion.div>
          ))}
          {traces.length === 0 && (
            <div className="text-gray-500 text-center mt-10 italic">
              Awaiting order execution...
            </div>
          )}
        </AnimatePresence>
      </div>
    </div>
  );
}