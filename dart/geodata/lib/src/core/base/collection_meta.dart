// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/meta.dart';

import 'resource_meta.dart';

/// Metadata for a collection resource.
///
/// The [id] of the collection can be used as a path segment in URLs.
class CollectionMeta extends ResourceMeta {
  /// Create a metadata instance for a collection resource.
  const CollectionMeta({
    required this.id,
    required super.title,
    super.description,
    required super.links,
    this.extent,
  });

  /// The required [id] of the collection.
  ///
  /// In some APIs this [id] could be used as a path segment on URL references.
  final String id;

  /// An optional geospatial [extent] for this collection.
  final GeoExtent? extent;

  @override
  List<Object?> get props => [id, title, description, links, extent];
}
