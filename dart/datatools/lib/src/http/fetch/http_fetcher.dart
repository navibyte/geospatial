// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:http/http.dart' as http;

import '../../api/exceptions.dart';
import '../../api/fetch.dart';
import '../../api/resolver.dart';

import 'http_adapter.dart';
import 'http_content.dart';
import 'http_exception.dart';
import 'http_validator.dart';

/// A [Fetcher] implementation for accessing HTTP or HTTPS resources.
class HttpFetcher extends Fetcher<HttpContent> with FetchMixin<HttpContent> {
  /// A HTTP fetcher using optional [endpoints].
  ///
  /// For each request on a server the proxy creates a new `http.Client`
  /// instance (of the [http](https://pub.dev/packages/http) package).
  ///
  /// An optional [validator] function handles how a HTTP response is
  /// converted to a [HttpContent] instance or thrown as [HttpException]. If
  /// not set, then only HTTP 200 OK responses are validated successful and
  /// returned as content.
  factory HttpFetcher.simple({
    List<Uri>? endpoints,
    HttpValidator validator = _validate200OK,
  }) =>
      HttpFetcher._(
        HttpAdapter.simple(),
        null,
        _endpointResolver(endpoints),
        validator,
      );

  /// A HTTP fetcher using the given HTTP [client] and optional [endpoints].
  ///
  /// An optional [validator] function handles how a HTTP response is
  /// converted to a [HttpContent] instance or thrown as [HttpException]. If
  /// not set, then only HTTP 200 OK responses are validated successful and
  /// returned as content.
  factory HttpFetcher.client(
    http.Client client, {
    List<Uri>? endpoints,
    HttpValidator validator = _validate200OK,
  }) =>
      HttpFetcher._(
        HttpAdapter.client(client),
        null,
        _endpointResolver(endpoints),
        validator,
      );

  /// A customized HTTP fetcher using the given [adapter] and [resolver].
  ///
  /// A custom [HttpAdapter] can be used to customize HTTP requests and
  /// a custom [UriResolver] to customize resolving from URI references to
  /// absolute URIs.
  ///
  /// An optional [validator] function handles how a HTTP response is
  /// converted to a [HttpContent] instance or thrown as [HttpException]. If
  /// not set, then only HTTP 200 OK responses are validated successful and
  /// returned as content.
  factory HttpFetcher.custom({
    required HttpAdapter adapter,
    required UriResolver resolver,
    HttpValidator validator = _validate200OK,
  }) =>
      HttpFetcher._(
        adapter,
        null,
        resolver,
        validator,
      );

  HttpFetcher._(
      this._adapter, this._baseHeaders, this._resolver, this._validator);

  final HttpAdapter _adapter;
  final Map<String, String>? _baseHeaders;
  final UriResolver _resolver;
  final HttpValidator _validator;

  @override
  HttpFetcher headers(Map<String, String>? headers) => HttpFetcher._(
        _adapter,
        _resolveHeaders(headers),
        _resolver,
        _validator,
      );

  @override
  Future<HttpContent> fetch(Uri reference) async {
    // resolve uri
    final uri = _resolver(reference);

    // do GET request and receive a "normal" HTTP response
    final response;
    try {
      response = await _adapter.get(uri, headers: _baseHeaders);
    } catch (e) {
      throw ClientException.failed(reference, e);
    }

    // form content instance from response (and original uri reference)
    return _validator(reference, response);
  }

  @override
  Future<HttpContent> fetchStream(Uri reference) async {
    // resolve uri
    final uri = _resolver(reference);

    // do GET request and receive a streaming HTTP response
    final response;
    try {
      response = await _adapter.getStreamed(uri, headers: _baseHeaders);
    } catch (e) {
      throw ClientException.failed(reference, e);
    }

    // form content instance  from response (and original uri reference)
    return _validator(reference, response);
  }

  Map<String, String>? _resolveHeaders(Map<String, String>? headers) {
    final h = _baseHeaders;
    if (h != null) {
      if (headers != null) {
        final copy = Map<String, String>.from(headers);
        copy.addAll(h);
        return copy;
      } else {
        return h;
      }
    } else {
      return headers != null ? Map<String, String>.from(headers) : null;
    }
  }
}

HttpContent _validate200OK(Uri reference, http.BaseResponse response) {
  if ((response.statusCode == 200)) {
    // for this default implementation:
    //     200 OK => return content
    return HttpContent(reference, response);
  } else {
    // for this default implementation:
    //     status codes other than 200 are "returned" as origin exceptions
    throw HttpException(reference, response);
  }
}

UriResolver _endpointResolver(List<Uri>? endpoints) {
  var _endpointIndex = -1;
  return (reference) {
    if (reference.hasScheme && reference.hasAuthority) {
      if (!(reference.isScheme('https') || reference.isScheme('http'))) {
        throw ClientException.uriNotAllowed(reference);
      }
      return reference;
    } else {
      if (endpoints != null) {
        _endpointIndex = (_endpointIndex + 1) % endpoints.length;
        return endpoints[_endpointIndex].resolveUri(reference);
      }
    }
    throw ClientException.uriNotAllowed(reference);
  };
}
