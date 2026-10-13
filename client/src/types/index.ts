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