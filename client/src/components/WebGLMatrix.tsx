'use client';
import { useEffect, useRef } from 'react';

export default function WebGLMatrix({ tps }: { tps: number }) {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    let animationFrameId: number;
    const slots = 16;
    const drops: number[] = Array(slots).fill(0);

    const draw = () => {
      // Semi-transparent black to create trailing effect
      ctx.fillStyle = 'rgba(11, 12, 16, 0.2)';
      ctx.fillRect(0, 0, canvas.width, canvas.height);

      ctx.font = '14px monospace';
      
      for (let i = 0; i < drops.length; i++) {
        // Map TPS to visual intensity
        const intensity = Math.random() > 0.1 ? '#836EF9' : '#00FF41'; 
        ctx.fillStyle = intensity;
        
        // Draw binary/hex data simulation
        const text = Math.random() > 0.5 ? '1' : '0';
        ctx.fillText(text, i * (canvas.width / slots) + 10, drops[i] * 20);

        if (drops[i] * 20 > canvas.height && Math.random() > 0.95) {
          drops[i] = 0;
        }
        // Speed relates to TPS
        drops[i] += (tps / 5000); 
      }

      animationFrameId = requestAnimationFrame(draw);
    };

    draw();

    return () => cancelAnimationFrame(animationFrameId);
  }, [tps]);

  return (
    <div className="relative w-full h-48 bg-monad-dark border border-gray-800 rounded-lg overflow-hidden">
      <div className="absolute top-2 left-2 text-xs font-mono text-monad-purple bg-monad-dark/80 p-1 rounded z-10">
        // PARALLEL STATE EXECUTION (16 THREADS)
      </div>
      <canvas
        ref={canvasRef}
        width={800}
        height={192}
        className="w-full h-full opacity-70"
      />
    </div>
  );
}