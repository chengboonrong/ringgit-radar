import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ringgit_radar/core/api/api_client.dart';
import 'package:ringgit_radar/core/widgets/error_view.dart';
import 'package:ringgit_radar/l10n/app_localizations.dart';

/// Answers every request with [status], or fails to connect when it is null.
class _Adapter implements HttpClientAdapter {
  _Adapter(this.status, [this.body = '{}']);
  final int? status;
  final String body;

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    if (status == null) throw DioException.connectionError(requestOptions: options, reason: 'refused');
    return ResponseBody.fromString(body, status!, headers: {'content-type': ['application/json']});
  }

  @override
  void close({bool force = false}) {}
}

ApiClient client(int? status, [String body = '{}']) => ApiClient(Dio()..httpClientAdapter = _Adapter(status, body));

Future<ApiException> caught(Future<Object?> f) async {
  try {
    await f;
  } on ApiException catch (e) {
    return e;
  }
  fail('no ApiException');
}

void main() {
  final en = lookupAppLocalizations(const Locale('en'));

  test('an unreachable server is a value naming what failed and why', () async {
    final e = await caught(client(null).highlights());
    expect(e.what, ApiWhat.highlights);
    expect(e.failure, ApiFailure.unreachable);
    expect(errorText(en, e), "Couldn't load Highlights. The Ringgit Radar server can't be reached.");
  });

  test('a status answer keeps the status', () async {
    final e = await caught(client(503).ranking('switch'));
    expect(e.what, ApiWhat.ranking);
    expect(e.failure, ApiFailure.status);
    expect(e.status, 503);
    expect(errorText(en, e), "Couldn't load the ranking. The server answered 503.");
  });

  test('an answer of the wrong shape', () async {
    final e = await caught(client(200, '[]').status());
    expect(e.failure, ApiFailure.badShape);
    expect(errorText(en, e), "Couldn't load data status. The answer was not in the expected shape.");
  });

  test('the English wording is what it was for every kind of request', () {
    String t(ApiWhat w) => errorText(en, ApiException(w, ApiFailure.status, 500));
    expect(t(ApiWhat.list), "Couldn't load the list. The server answered 500.");
    expect(t(ApiWhat.genres), "Couldn't load genres. The server answered 500.");
    expect(t(ApiWhat.game), "Couldn't load this game. The server answered 500.");
    expect(errorText(en, StateError('x')), en.somethingWentWrong);
  });
}
