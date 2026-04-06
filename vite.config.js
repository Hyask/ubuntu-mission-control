import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

const apiProxy = {
  target: 'https://tests-api.ubuntu.com',
  changeOrigin: true,
  rewrite: path => path.replace(/^\/api/, ''),
  configure: proxy => {
    proxy.on('proxyReq', proxyReq => {
      proxyReq.setHeader('X-CSRF-Token', '1')
    })
  },
}

export default defineConfig({
  plugins: [svelte()],
  server: {
    port: 3000,
    proxy: { '/api': apiProxy },
  },
  preview: {
    port: 3000,
    proxy: { '/api': apiProxy },
  },
})
