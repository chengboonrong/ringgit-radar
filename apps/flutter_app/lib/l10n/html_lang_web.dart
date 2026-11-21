import 'dart:js_interop';

@JS('document.documentElement')
external _Element get _root;

extension type _Element(JSObject _) implements JSObject {
  external set lang(String value);
}

/// Keeps the html lang attribute on the language the app is showing, for screen readers and the browser's translate offer.
void setHtmlLang(String code) => _root.lang = code;
