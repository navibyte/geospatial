// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';
import 'dart:typed_data';

import 'dart:io' show File;

import 'package:http_parser/http_parser.dart' show MediaType;

import '../../api/content.dart';
import '../../api/exceptions.dart';

/// File content providing body and stream access for a file resource.
class FileContent extends Content {
  FileContent(this.reference, this.file,
      {String? contentType, this.encoding = utf8, this.contentLength})
      : mediaType = Head.mediaTypeOf(contentType);

  @override
  final Uri reference;

  /// The original file for this content.
  final File file;

  @override
  final MediaType mediaType;

  @override
  final Encoding encoding;

  @override
  final int? contentLength;

  @override
  Future<String> get text async {
    try {
      return await file.readAsString(encoding: encoding);
    } catch (e) {
      throw ClientException.readingTextFailed(e);
    }
  }

  @override
  Future<Uint8List> get bytes async {
    try {
      return await file.readAsBytes();
    } catch (e) {
      throw ClientException.readingBytesFailed(e);
    }
  }

  @override
  Future<ByteData> byteData([int start = 0, int? end]) async {
    try {
      return ByteData.sublistView(await file.readAsBytes(), start, end);
    } catch (e) {
      throw ClientException.readingBytesFailed(e);
    }
  }

  @override
  Future<dynamic> decodeJson() async {
    try {
      return json.decode(await file.readAsString(encoding: encoding));
    } catch (e) {
      throw ClientException.decodingJsonFailed(e);
    }
  }

  @override
  Future<Stream<List<int>>> get stream async {
    try {
      return file.openRead();
    } catch (e) {
      throw ClientException.openingStreamFailed(e);
    }
  }
}
