// Copyright 2020 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a "BSD-3-Clause"-style license, please
// see the LICENSE file.

import 'package:meta/meta.dart';

import 'package:equatable/equatable.dart';

/// Represents a resource link.
///
/// Compatible with: http://schemas.opengis.net/ogcapi/features/part1/1.0/openapi/schemas/link.yaml
@immutable
class Link with EquatableMixin {
  /// Link with [href]. Optional: [rel], [type], [hreflang], [title], [length].
  const Link(
      {required this.href,
      this.rel,
      this.type,
      this.hreflang,
      this.title,
      this.length});

  /// A link from decoded JSON objects.
  Link.fromJson(Map<String, dynamic> json)
      : href = json['href'],
        rel = json['rel'],
        type = json['type'],
        hreflang = json['hreflang'],
        title = json['title'],
        length = json['length'];

  final String href;

  final String? rel;

  final String? type;

  final String? hreflang;

  final String? title;

  final int? length;

  @override
  List<Object?> get props => [href, rel, type, hreflang, title, length];
}
