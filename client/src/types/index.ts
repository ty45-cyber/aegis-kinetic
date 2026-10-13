export type Side = 'Bid' | 'Ask';

export interface Order {
  price: number;
  amount: number;
  side: Side;
  slotId?: number;
}

export interface StateTrace {
  id: string;
  txHash: string;
  slotId: number;
  latencyMs: number;
  status: 'Confirmed' | 'Pending' | 'Reverted';
  timestamp: number;
}

export interface KineticMetrics {
  currentPrice: number;
  dynamicFeeBps: number;
  velocity: number;
  tps: number;
}

export interface BlockTrace {
  slot: number;
  hash: string;
  tps: number;
  latencyMs: number;
  confirmed: boolean;
}

export interface WasmEngine {
  execute_order(payload: Uint8Array): boolean;
}

export interface EngineContext {
  engine: WasmEngine | null;
  isReady: boolean;
  error: Error | null;
}