// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart' show MediaType;

import '../../api/content.dart';
import '../../api/exceptions.dart';

/// HTTP content providing body and stream access for a HTTP response data.
class HttpContent extends Content {
  HttpContent(this.reference, this.response, {Encoding fallback = latin1})
      : _fallback = fallback;

  @override
  final Uri reference;

  /// The HTTP [response] as an origin for this content.
  final http.BaseResponse response;

  @override
  MediaType get mediaType => Head.mediaTypeOf(response.headers['content-type']);

  final Encoding _fallback;

  @override
  Encoding get encoding =>
      Encoding.getByName(mediaType.parameters['charset']) ?? _fallback;

  @override
  int? get contentLength => response.contentLength;

  @override
  Future<String> get text async {
    try {
      final res = response;
      if (res is http.StreamedResponse) {
        return await res.stream.bytesToString();
      } else {
        return (res as http.Response).body;
      }
    } catch (e) {
      throw ClientException.readingTextFailed(e);
    }
  }

  @override
  Future<Uint8List> get bytes async {
    try {
      final res = response;
      if (res is http.StreamedResponse) {
        return await res.stream.toBytes();
      } else {
        return (res as http.Response).bodyBytes;
      }
    } catch (e) {
      throw ClientException.readingBytesFailed(e);
    }
  }

  @override
  Future<ByteData> byteData([int start = 0, int? end]) async {
    try {
      final res = response;
      if (res is http.StreamedResponse) {
        return ByteData.sublistView(await res.stream.toBytes(), start, end);
      } else {
        return ByteData.sublistView(
            (res as http.Response).bodyBytes, start, end);
      }
    } catch (e) {
      throw ClientException.readingBytesFailed(e);
    }
  }

  @override
  Future<dynamic> decodeJson() async {
    try {
      final res = response;
      if (res is http.StreamedResponse) {
        return json.decode(await res.stream.bytesToString());
      } else {
        return json.decode((res as http.Response).body);
      }
    } catch (e) {
      throw ClientException.decodingJsonFailed(e);
    }
  }

  @override
  Future<Stream<List<int>>> get stream async {
    try {
      final res = response;
      if (res is http.StreamedResponse) {
        return res.stream;
      } else {
        return http.ByteStream.fromBytes((res as http.Response).bodyBytes);
      }
    } catch (e) {
      throw ClientException.openingStreamFailed(e);
    }
  }
}
