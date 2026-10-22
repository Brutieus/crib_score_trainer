# ONNX Runtime Web 1.30.0

Browser build of [ONNX Runtime](https://github.com/microsoft/onnxruntime) used to run card detection in the page. These files are loaded from this site. The app does not fetch them from a CDN.

| File | Role |
| --- | --- |
| `ort.webgpu.min.js` | Script bundle. WebGPU when the browser has it, otherwise WebAssembly. |
| `ort-wasm-simd-threaded.asyncify.mjs` | Loader the script imports. Must stay next to the `.wasm`. |
| `ort-wasm-simd-threaded.asyncify.wasm` | WebAssembly binary from the same 1.30.0 build. |

`numThreads` is forced to 1 so GitHub Pages can serve the site without cross-origin isolation headers.

License: MIT. See `LICENSE`. Do not mix these files with another ONNX Runtime version.
