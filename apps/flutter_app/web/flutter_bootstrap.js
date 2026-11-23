{{flutter_js}}
{{flutter_build_config}}

// No service worker: the app lives under /app/, where Flutter's caching worker would never serve anything,
// and leaving it out means a returning visitor can never be stuck on an old offline copy.
_flutter.loader.load({
  config: {
    // the one fallback font the engine fetches at start-up comes from our own server (assets/gfonts), not
    // Google; the engine puts its asset base (<base href>assets/) in front of this, so it stays relative
    fontFallbackBaseUrl: "assets/gfonts/"
  }
});
