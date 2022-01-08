// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:equatable/equatable.dart';

import 'package:meta/meta.dart';

import '/src/common/links.dart';

/// Basic metadata about some resource.
@immutable
class ResourceMeta with LinksAware, EquatableMixin {
  /// A new resource metadata instance with [title], [description] and [links].
  const ResourceMeta({
    required this.title,
    this.description,
    required this.links,
  });

  /// The required title for a resource.
  final String title;

  /// An optional description for a resource.
  final String? description;

  @override
  final Links links;

  @override
  List<Object?> get props => [title, description, links];
}
