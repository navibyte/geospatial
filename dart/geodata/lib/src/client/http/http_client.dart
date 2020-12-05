// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'dart:convert';
import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:http/http.dart' as http;

import '../../utils/format/mime.dart';

import '../client.dart';
import '../content.dart';
import '../endpoint.dart';
import '../query.dart';

/// A basic HTTP client implementation (using https://pub.dev/packages/http).
class HttpApiClient extends ApiClient {
  /// Creates a client from a list of [endpoints] with at least one member.
  factory HttpApiClient.endpoints(List<Endpoint> endpoints) {
    return HttpApiClient._endpoints(endpoints);
  }

  HttpApiClient._endpoints(this._endpoints) : assert(_endpoints.isNotEmpty);

  final List<Endpoint> _endpoints;
  int _endpointIndex = -1;

  Endpoint _nextEndpoint() {
    _endpointIndex = (_endpointIndex + 1) % _endpoints.length;
    return _endpoints[_endpointIndex];
  }

  Future<http.Response> _readResponse(Query query) {
    return http.get(query.locate(_nextEndpoint()).url);
  }

  @override
  Future<Content> read(Query query) async {
    return _ResponseContent(
      query: query,
      response: await _readResponse(query),
    );
  }
}

class _ResponseContent extends Content {
  const _ResponseContent({required this.query, required this.response});

  @override
  final Query query;

  final http.Response response;

  @override
  KnownMime get mime => toKnownMime(contentType);

  @override
  String get contentType =>
      response.headers['content-type'] ?? 'application/octet-stream';

  @override
  int get length => response.contentLength;

  @override
  String body() => response.body;

  @override
  Uint8List bodyBytes() => response.bodyBytes;

  @override
  dynamic decodeJson() => json.decode(response.body);
}
