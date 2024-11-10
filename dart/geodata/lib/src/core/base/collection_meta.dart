// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
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
    super.attribution,
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
  String toString() {
    return '$id;$title;$description;$attribution;$links;$extent';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionMeta &&
          id == other.id &&
          title == other.title &&
          description == other.description &&
          attribution == other.attribution &&
          links == other.links &&
          extent == other.extent);

  @override
  int get hashCode =>
      Object.hash(id, title, description, attribution, links, extent);
}
