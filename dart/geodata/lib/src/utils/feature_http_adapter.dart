// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:meta/meta.dart';

import '/src/common/service/service_exception.dart';
import '/src/core/features/feature_failure.dart';

const _acceptJSON = {'accept': 'application/json'};
const _expectJSON = ['application/json'];

/// An adapter to fetch HTTP client, used by a feature service.
@internal
class FeatureHttpAdapter {
  /// Create an adapter with an optional [client], [headers] and [extraParams].
  const FeatureHttpAdapter({
    http.Client? client,
    Map<String, String>? headers,
    Map<String, String>? extraParams,
  })  : _client = client,
        _baseHeaders = headers,
        _extraParams = extraParams;

  final http.Client? _client;
  final Map<String, String>? _baseHeaders;
  final Map<String, String>? _extraParams;

  /// Makes `GET` request to [url] with optional [headers].
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) {
    final httpUrl = _handleExtraParams(url);
    final httpHeaders = _combineHeaders(headers);

    //print('calling $httpUrl');
    return _client != null
        ? _client!.get(httpUrl, headers: httpHeaders)
        : http.get(httpUrl, headers: httpHeaders);
  }

  /// Makes `GET` request to [url] with optional [headers].
  ///
  /// Returns an entity mapped from JSON Object using [toEntity].
  Future<T> getEntityFromJsonObject<T>(
    Uri url, {
    required T Function(
      Map<String, dynamic> data,
      Map<String, String> responseHeaders,
    ) toEntity,
    Map<String, String>? headers = _acceptJSON,
    List<String>? expect = _expectJSON,
  }) =>
      getEntityFromJson(
        url,
        toEntity: (data, responseHeaders) =>
            toEntity(data as Map<String, dynamic>, responseHeaders),
        headers: headers,
        expect: expect,
      );

  /// Makes `GET` request to [url] with optional [headers].
  ///
  /// Returns an entity mapped from JSON element using [toEntity].
  Future<T> getEntityFromJson<T>(
    Uri url, {
    required T Function(
      dynamic data,
      Map<String, String> responseHeaders,
    ) toEntity,
    Map<String, String>? headers = _acceptJSON,
    List<String>? expect = _expectJSON,
  }) async {
    try {
      final response = await get(url, headers: headers);
      switch (response.statusCode) {
        case 200:
          // optionally check that we got content type that was expected
          // if expect list contains ..
          //     "application/json"
          // .. then for example these types from header 'content-type' are ok
          //     "application/json"
          //     "application/json; charset=utf-8"
          // not perfect checking anyways
          if (expect != null) {
            var ok = false;
            final type = response.headers['content-type'];
            if (type != null) {
              for (final exp in expect) {
                if (type.startsWith(exp)) {
                  ok = true;
                  break;
                }
              }
            }
            if (!ok) {
              throw FormatException('Content type "$type" not expected.');
            }
          }

          // decode JSON
          final data = json.decode(response.body);

          // map JSON data to an entity
          return toEntity(data, response.headers);
        case 302:
          throw const ServiceException(FeatureFailure.found);
        case 303:
          throw const ServiceException(FeatureFailure.seeOther);
        case 304:
          throw const ServiceException(FeatureFailure.notModified);
        case 307:
          throw const ServiceException(FeatureFailure.temporaryRedirect);
        case 308:
          throw const ServiceException(FeatureFailure.permanentRedirect);
        case 400:
          throw const ServiceException(FeatureFailure.badRequest);
        case 401:
          throw const ServiceException(FeatureFailure.unauthorized);
        case 403:
          throw const ServiceException(FeatureFailure.forbidden);
        case 404:
          throw const ServiceException(FeatureFailure.notFound);
        case 405:
          throw const ServiceException(FeatureFailure.methodNotAllowed);
        case 406:
          throw const ServiceException(FeatureFailure.notAcceptable);
        case 500:
          throw const ServiceException(FeatureFailure.internalServerError);
        default:
          throw const ServiceException(FeatureFailure.queryFailed);
      }
    } on ServiceException<FeatureFailure> {
      rethrow;
    } catch (e, st) {
      // other exceptions (including errors)
      throw ServiceException(FeatureFailure.clientError, cause: e, trace: st);
    }
  }

  Map<String, String>? _combineHeaders(Map<String, String>? headers) {
    if (_baseHeaders != null) {
      if (headers != null) {
        return Map.from(_baseHeaders!)..addAll(headers);
      } else {
        return _baseHeaders;
      }
    } else {
      return headers;
    }
  }

  Uri _handleExtraParams(Uri url) {
    if (_extraParams == null) {
      return url;
    } else {
      final resultParams = Map.of(url.queryParameters);
      for (final param in _extraParams!.entries) {
        resultParams.putIfAbsent(param.key, () => param.value);
      }
      return url.replace(queryParameters: resultParams);
    }
  }
}
