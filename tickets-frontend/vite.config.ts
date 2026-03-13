/// <reference types="vitest" />
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import legacy from '@vitejs/plugin-legacy'

export default defineConfig({
  plugins: [
    react(),
    legacy({
      targets: ['chrome >= 70', 'firefox >= 63', 'edge >= 79', 'safari >= 12'],
      additionalLegacyPolyfills: ['regenerator-runtime/runtime'],
    }),
  ],
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          'vendor-base': ['react', 'react-dom', 'react-router-dom'],
          'vendor-api': ['@tanstack/react-query', 'axios'],
          'vendor-ui': ['lucide-react', 'recharts'],
          'vendor-signalr': ['@microsoft/signalr'],
          'vendor-state': ['zustand', 'sileo'],
        },
      },
    },
  },
  server: {
    port: 5173,
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
      '/hubs': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        ws: true,
        configure: (proxy: any) => {
          proxy.on('error', (err: Error) => {
            console.log('[proxy /hubs] error:', err.message);
          });
        },
      },
    },
  },
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: './src/test/setup.ts',
    css: true,
  },
})
