// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import '/src/common/links/links.dart';
import '/src/common/links/links_aware.dart';

/// Basic metadata about some resource.
@immutable
class ResourceMeta with LinksAware, EquatableMixin {
  /// A new resource metadata instance with [title], [description],
  /// [attribution] and [links].
  const ResourceMeta({
    required this.title,
    this.description,
    this.attribution,
    required this.links,
  });

  /// The required title for a resource.
  final String title;

  /// An optional description for a resource.
  final String? description;

  /// An optional attribution about a resource, intended for presentation to an
  /// user.
  final String? attribution;

  @override
  final Links links;

  @override
  List<Object?> get props => [title, description, attribution, links];
}
