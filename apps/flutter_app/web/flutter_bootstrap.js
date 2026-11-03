{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  serviceWorkerSettings: {
    serviceWorkerVersion: {{flutter_service_worker_version}}
  },
  config: {
    // the one fallback font the engine fetches at start-up comes from our own server (assets/gfonts), not Google
    fontFallbackBaseUrl: "/assets/assets/gfonts/"
  }
});
