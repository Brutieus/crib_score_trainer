// In-page card detector. Loaded with the page, but the runtime and model
// download on the first photo. Paths follow <base href> so GitHub Pages
// (a project site) and a local dev server both work.
(function () {
  var sessionPromise = null;

  function asset(rel) {
    var base = document.querySelector('base');
    var root = base && base.href ? base.href : document.baseURI;
    return new URL(rel, root).href;
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var found = document.querySelector('script[data-crib-ort="1"]');
      if (found) {
        if (found.getAttribute('data-loaded') === '1') {
          resolve();
        } else {
          found.addEventListener('load', function () { resolve(); }, { once: true });
          found.addEventListener('error', function () {
            reject(new Error('Could not load ONNX Runtime'));
          }, { once: true });
        }
        return;
      }
      var script = document.createElement('script');
      script.src = src;
      script.setAttribute('data-crib-ort', '1');
      script.onload = function () {
        script.setAttribute('data-loaded', '1');
        resolve();
      };
      script.onerror = function () {
        reject(new Error('Could not load ONNX Runtime'));
      };
      document.head.appendChild(script);
    });
  }

  function ensureSession() {
    if (sessionPromise) return sessionPromise;
    sessionPromise = (async function () {
      await loadScript(asset('ort/ort.webgpu.min.js'));
      var ort = globalThis.ort;
      if (!ort) throw new Error('ONNX Runtime did not start');
      ort.env.wasm.wasmPaths = asset('ort/');
      ort.env.wasm.numThreads = 1;
      var modelUrl = asset('models/cards.onnx');
      try {
        return await ort.InferenceSession.create(modelUrl, {
          executionProviders: ['webgpu'],
        });
      } catch (_) {
        return await ort.InferenceSession.create(modelUrl, {
          executionProviders: ['wasm'],
        });
      }
    })().catch(function (err) {
      sessionPromise = null;
      throw err;
    });
    return sessionPromise;
  }

  async function detectCards(input) {
    var session = await ensureSession();
    var ort = globalThis.ort;
    var inputName = session.inputNames[0];
    var tensor = new ort.Tensor('float32', input, [1, 3, 640, 640]);
    var feeds = {};
    feeds[inputName] = tensor;
    var results = await session.run(feeds);
    var output = results[session.outputNames[0]];
    return {
      data: new Float32Array(output.data),
      dims: Array.from(output.dims).join(','),
    };
  }

  globalThis.cribDetect = {
    ensureSession: ensureSession,
    detectCards: detectCards,
  };
})();
