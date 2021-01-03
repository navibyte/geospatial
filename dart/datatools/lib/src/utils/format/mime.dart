// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

// ignore: import_of_legacy_library_into_null_safe
import 'package:http_parser/http_parser.dart';

import '../../client/base/content.dart';

/// Parse a [KnownMime] instance from the "content-type" string.
KnownMime toKnownMime(String? contentType) {
  final media = toMediaType(contentType);

  KnownType? type;
  switch (media.type) {
    case 'application':
      switch (media.subtype) {
        case 'json':
          type = KnownType.json;
          break;
        case 'ld+json':
          type = KnownType.ld_json;
          break;
        case 'geo+json':
          type = KnownType.geo_json;
          break;
        case 'gml+xml':
          type = KnownType.xml_gml;
          break;
      }
      break;
    case 'text':
      switch (media.subtype) {
        case 'html':
          type = KnownType.html;
          break;
      }
      break;
  }

  return KnownMime(
    type ?? KnownType.unknown,
    version: media.parameters['version'],
    profile: media.parameters['profile'],
  );
}

/// Parse a `http_parse.MediaType` instance from the "content-type" string.
MediaType toMediaType(String? contentType) => contentType != null
    ? MediaType.parse(contentType)
    : MediaType('application', 'octet-stream');
