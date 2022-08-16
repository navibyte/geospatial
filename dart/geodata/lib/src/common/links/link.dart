// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/dataflow

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

/// Represents a resource link.
///
/// Compatible with: http://schemas.opengis.net/ogcapi/features/part1/1.0/openapi/schemas/link.yaml
@immutable
class Link with EquatableMixin {
  /// The `href` part of a link.
  final Uri href;

  /// An optional `rel` part of a link.
  final String? rel;

  /// An optional `type` part of a link.
  final String? type;

  /// An optional `hreflang` part of a link.
  final String? hreflang;

  /// An optional `title` part of a link.
  final String? title;

  /// An optional `length` part of a link.
  final int? length;

  /// Link with [href]. Optional: [rel], [type], [hreflang], [title], [length].
  const Link({
    required this.href,
    this.rel,
    this.type,
    this.hreflang,
    this.title,
    this.length,
  });

  /// Create a new link from [data] (ie. a decoded JSON object or a href link).
  ///
  /// [data] is allowed to be `Map<String, dynamic>` (containing link
  /// attributes) or `String` (containing only a `href` part of a link).
  ///
  /// Throws `FormatException` if cannot parse data.
  factory Link.fromData(dynamic data) {
    try {
      if (data is Map<String, dynamic>) {
        return Link(
          // get required fields (throws if data is unavailable or invalid)
          href: Uri.parse(data['href'] as String),

          // optional fields (null if data is unavailable, throws if invalid)
          rel: data['rel'] as String?,
          type: data['type'] as String?,
          hreflang: data['hreflang'] as String?,
          title: data['title'] as String?,
          length: data['length'] as int?,
        );
      } else if (data is String) {
        return Link(href: Uri.parse(data));
      }
      throw FormatException('Cannot create a link from $data');
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Cannot create a link', e);
    }
  }

  /// Converts this link to a data object.
  Map<String, dynamic> toData() => {
        // set required fields
        'href': href,

        // set optional fields if available
        if (rel != null) 'rel': rel,
        if (type != null) 'type': type,
        if (hreflang != null) 'hreflang': hreflang,
        if (title != null) 'title': title,
        if (length != null) 'length': rel,
      };

  @override
  List<Object?> get props => [href, rel, type, hreflang, title, length];
}
