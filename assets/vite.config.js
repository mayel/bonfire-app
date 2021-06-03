
import { defineConfig } from 'vite'

// https://vitejs.dev/config/
export default defineConfig({
  publicDir: "./static",
  build: {
    manifest: true,
    target: "es2018",
    outDir: "../priv/static", // phoenix expects our files here
    emptyOutDir: true, // cleanup previous builds
    polyfillDynamicImport: true,
    sourcemap: true, // do we want to debug our code in production?
    assetsInlineLimit: 0,
    rollupOptions: {
      input: {
        live: "js/live.js",
        non_live: "js/non_live.js",
        app: "css/app.scss"
      },
      output: {
        entryFileNames: "js/[name].js",
        chunkFileNames: "js/[name].js",
        assetFileNames: "[ext]/[name][extname]"
      }
    },
  },
  plugins: []
})