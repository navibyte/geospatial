// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Fetch API binding to HTTP and HTTPS resources.
///
/// Usage: import `package:datatools/fetch_http.dart`
library fetch_http;

export 'fetch_api.dart';
export 'src/http/fetch.dart';

import 'dart:typed_data';

import 'src/api/content.dart';
import 'src/http/fetch.dart';

/// Fetch (read fully) content body from a HTTP(S) resource identified by [url].
///
/// Throws an [ApiException] if fetching fails. Also response status codes other
/// than codes for success are thrown as exceptions.
Future<Content> fetch(Uri url, {Map<String, String>? headers}) =>
    HttpFetcher.simple().headers(headers).fetch(url);

/// Fetch content as a stream from a HTTP(S) resource identified by [url].
///
/// Throws an [ApiException] if fetching fails. Also response status codes other
/// than codes for success are thrown as exceptions.
Future<Content> fetchStream(Uri url, {Map<String, String>? headers}) =>
    HttpFetcher.simple().headers(headers).fetchStream(url);

/// Fetch content body as text from a HTTP(S) resource identified by [url].
///
/// Throws an [ApiException] if fetching fails. Also response status codes other
/// than codes for success are thrown as exceptions.
Future<String> fetchText(Uri url, {Map<String, String>? headers}) =>
    HttpFetcher.simple().headers(headers).fetchText(url);

/// Fetch content body as bytes from a HTTP(S) resource identified by [url].
///
/// Throws an [ApiException] if fetching fails. Also response status codes other
/// than codes for success are thrown as exceptions.
Future<Uint8List> fetchBytes(Uri url, {Map<String, String>? headers}) =>
    HttpFetcher.simple().headers(headers).fetchBytes(url);

/// Fetch content body as JSON data from a HTTP(S) resource identified by [url].
///
/// Throws an [ApiException] if fetching fails. Also response status codes other
/// than codes for success are thrown as exceptions.
Future<dynamic> fetchJson(Uri url, {Map<String, String>? headers}) =>
    HttpFetcher.simple().headers(headers).fetchJson(url);
