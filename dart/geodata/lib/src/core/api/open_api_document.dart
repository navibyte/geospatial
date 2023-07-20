// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '/src/common/meta/meta_aware.dart';

/// An OpenAPI document for some service with raw content parsed in [meta].
///
/// Note: this class wraps decoded JSON Object from a JSON document containing
/// OpenAPI definition. To utilize such data JSON Object tree in [meta] must be
/// traversed as needed. 
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
///   final servers = document.meta['servers'] as Iterable<dynamic>;
///   for (final s in servers) {
///     final server = s as Map<String, dynamic>;
///     final url = server['url'];
///     final desc = server['description'];
///     print('  $url : $desc');
///   }
/// }
/// ```
@immutable
class OpenAPIDocument with MetaAware, EquatableMixin {
  /// An OpenAPI document for some service with raw content parsed in [meta].
  const OpenAPIDocument({
    Map<String, dynamic>? meta,
  }) : meta = meta ?? const {};

  /// The OpenAPI document as a data object (ie. data from a JSON Object).
  @override
  final Map<String, dynamic> meta;

  /// The version number of the OpenAPI Specification that this OpenAPI document
  /// uses.
  String get openapi => meta['openapi'] as String;

  @override
  List<Object?> get props => [meta];
}
