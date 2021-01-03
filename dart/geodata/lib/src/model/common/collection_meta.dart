// Copyright (c) 2020-2021 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geocore/meta_extent.dart';

import '../base.dart';

import 'links_meta.dart';

/// Metadata for a collection resource.
class CollectionMeta extends Meta {
  const CollectionMeta(
      {required this.id,
      required this.links,
      this.extent,
      required String title,
      String? description})
      : super(title: title, description: description);

  /// The identifier for the collection. Can be used as a path segment in URIs.
  final String id;

  /// Links for the collection.
  final LinksMeta links;

  /// Geospatial extent for this dataset.
  final Extent? extent;

  @override
  List<Object?> get props => [id, extent, title, description];
}
