// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:http/http.dart' as http;

/// An adapter that [HttpFetcher] instances uses to call `http.Client`.
///
/// This interface can be overridden to implement more sophisticated logic
/// when calling HTTP, like error management, fault-tolerance, re-try
/// mechanism, handling forward status codes, caching etc.
abstract class HttpAdapter {
  const HttpAdapter();

  /// A simple HTTP adapter that creates a new `http.Client` for each request.
  ///
  /// This default adapter just forwards HTTP GET requests to `http.Client`.
  factory HttpAdapter.simple() => _HttpClientAdapterBase(null);

  /// A HTTP adapter using the given HTTP [client].
  ///
  /// The lifecycle (closing it) of the [client] must be managed by caller of
  /// this factory.
  ///
  /// This default adapter just forwards HTTP GET requests to `http.Client`.
  factory HttpAdapter.client(http.Client client) =>
      _HttpClientAdapterBase(client);

  /// Makes an HTTP GET request to a resource identified by [uri].
  ///
  /// An implementation could provide re-try or forwarding mechanism, only the
  /// final response is returned to a client.
  Future<http.Response> get(Uri uri, {Map<String, String>? headers});

  /// Makes an HTTP GET streamed request to a resource identified by [uri].
  ///
  /// An implementation could provide re-try or forwarding mechanism, only the
  /// final response is returned to a client.
  Future<http.StreamedResponse> getStreamed(Uri uri,
      {Map<String, String>? headers});
}

class _HttpClientAdapterBase extends HttpAdapter {
  _HttpClientAdapterBase(this._client);

  /// An optional HTTP client to be used on persistent connections.
  final http.Client? _client;

  @override
  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) {
    // do GET request using persistent or one-shot HTTP client
    final persistent = _client;
    return persistent != null
        ? persistent.get(uri, headers: headers)
        : http.get(uri, headers: headers);
  }

  @override
  Future<http.StreamedResponse> getStreamed(Uri uri,
      {Map<String, String>? headers}) {
    // do streamed GET request using persistent or one-shot HTTP client
    final req = http.Request('GET', uri);
    if (headers != null) req.headers.addAll(headers);
    final persistent = _client;
    if (persistent != null) {
      return persistent.send(req);
    } else {
      final c = http.Client();
      try {
        return c.send(req);
      } finally {
        c.close();
      }
    }
  }
}
