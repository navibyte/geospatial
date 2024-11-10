// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/utils/object_utils.dart';

/// An OpenAPI document for some service with raw content parsed in [content].
///
/// Note: this class wraps decoded JSON Object from a JSON document containing
/// OpenAPI definition. To utilize such data JSON Object tree in [content] must
/// be traversed as needed.
///
/// In future this class might containg also helper methods to access certain
/// objects and fields according to the OpenAPI schema. Currently there is only
/// the [openapi] member, other elements must be accessed from raw data.
///
/// See also:
/// * https://www.openapis.org/
/// * https://spec.openapis.org/oas/latest.html
/// * https://swagger.io/specification/
///
/// Example:
/// ```dart
/// void _printOpenAPI(OpenAPIDocument document) {
///   print('OpenAPI ${document.openapi}');
///   final servers = document.content['servers'] as Iterable<dynamic>;
///   for (final s in servers) {
///     final server = s as Map<String, dynamic>;
///     final url = server['url'] as String;
///     final desc = server['description'] as String?;
///     print('  $url : $desc');
///   }
/// }
/// ```
@immutable
class OpenAPIDocument {
  /// The OpenAPI document as a data object (ie. data from a JSON Object).
  final Map<String, dynamic> content;

  /// The version number of the OpenAPI Specification that this OpenAPI document
  /// uses.
  final String openapi;

  const OpenAPIDocument._({
    this.content = const {},
    required this.openapi,
  });

  /// Parses Open API document for a service from Open API data in [content].
  factory OpenAPIDocument.fromJson(Map<String, dynamic> content) =>
      OpenAPIDocument._(
        content: content,
        openapi: content['openapi'] as String, // required
      );

  @override
  String toString() => '$openapi;$mapToString(content)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpenAPIDocument &&
          openapi == other.openapi &&
          testMapEquality(content, other.content));

  @override
  int get hashCode => Object.hash(openapi, mapHashCode(content));
}
