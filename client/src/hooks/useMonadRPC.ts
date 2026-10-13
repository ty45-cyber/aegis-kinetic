'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import type { BlockTrace } from '../types';

const MONAD_WS_URL = process.env.NEXT_PUBLIC_MONAD_WS_URL || 'wss://testnet-rpc.monad.xyz/ws';

export const useMonadRPC = () => {
  const [isConnected, setIsConnected] = useState(false);
  const [traces, setTraces] = useState<BlockTrace[]>([]);
  const wsRef = useRef<WebSocket null |>(null);
  const reconnectTimeoutRef = useRef<NodeJS.Timeout>();
  
  // Use a ref for the buffer to batch React state updates (prevents render thrashing)
  const traceBuffer = useRef<BlockTrace[]>([]);

  const connect = useCallback(() => {
    if (wsRef.current?.readyState === WebSocket.OPEN) return;

    const ws = new WebSocket(MONAD_WS_URL);

    ws.onopen = () => {
      setIsConnected(true);
      // Subscribe to Monad slot trace updates
      ws.send(JSON.stringify({
        jsonrpc: '2.0',
        id: 1,
        method: 'eth_subscribe',
        params: ['newHeads']
      }));
    };

    ws.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);
        if (data?.method === 'eth_subscription') {
          const newTrace: BlockTrace = {
            slot: parseInt(data.params.result.number, 16),
            hash: data.params.result.hash,
            tps: Math.floor(Math.random() * 10000), // Replace with actual TPS calc
            latencyMs: Date.now() - parseInt(data.params.result.timestamp, 16) * 1000,
            confirmed: true
          };
          traceBuffer.current.push(newTrace);
        }
      } catch (e) {
        console.error('Failed to parse Monad RPC message', e);
      }
    };

    ws.onclose = () => {
      setIsConnected(false);
      // Exponential backoff could be implemented here
      reconnectTimeoutRef.current = setTimeout(connect, 1000);
    };

    ws.onerror = (err) => {
      console.error('Monad WS Error:', err);
      ws.close();
    };

    wsRef.current = ws;
  }, []);

  // Flush buffer to React state at 60fps
  useEffect(() => {
    const interval = setInterval(() => {
      if (traceBuffer.current.length > 0) {
        setTraces(prev => [...traceBuffer.current, ...prev].slice(0, 50));
        traceBuffer.current = [];
      }
    }, 16); // ~60fps
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    connect();
    return () => {
      if (wsRef.current) wsRef.current.close();
      if (reconnectTimeoutRef.current) clearTimeout(reconnectTimeoutRef.current);
    };
  }, [connect]);

  return { isConnected, traces };
};