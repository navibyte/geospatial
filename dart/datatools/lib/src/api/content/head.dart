// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'dart:convert';

import 'package:http_parser/http_parser.dart' show MediaType;

/// An interface providing meta data for some content.
abstract class Head {
  const Head();

  /// The expected media type.
  ///
  /// The value can be any registered MIME type, like `text/html`,
  /// `application/json` or `application/geo+json`.
  ///
  /// The default value is `application/octet-stream` or generic binary data
  /// with unknown type.
  MediaType get mediaType;

  /// The expected charset [encoding].
  Encoding get encoding;

  /// An optional content length as number of bytes.
  ///
  /// Returns null if the length is unknown in advance.
  int? get contentLength;

  /// Checks if "content-type" equals with [primaryType] and one of sub types.
  ///
  /// To check exact content type: `hasType('application', 'json')`
  ///
  /// Multiple sub type choices: `hasType('application', 'json', 'geo+json')`
  ///
  /// This checks only primary type and sub type components of "content-type"
  /// header values.
  bool hasType(String primaryType, String subType0,
      [String? orSubType1,
      String? orSubType2,
      String? orSubType3,
      String? orSubType4]) {
    if (mediaType.type == primaryType) {
      final sub = mediaType.subtype;
      if (sub == subType0) return true;
      if (orSubType1 != null) {
        if (sub == orSubType1) return true;
        if (orSubType2 != null) {
          if (sub == orSubType2) return true;
          if (orSubType3 != null) {
            if (sub == orSubType3) return true;
            if (orSubType4 != null) {
              if (sub == orSubType4) return true;
            }
          }
        }
      }
    }

    return false;
  }

  /// Parses [MediaType] instance from [contentType].
  ///
  /// `MediaType('application', 'octet-stream')` is returned if [contentType] is
  /// null.
  static MediaType mediaTypeOf(String? contentType) => contentType != null
      ? MediaType.parse(contentType)
      : MediaType('application', 'octet-stream');
}
