// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import '/src/core/base/collection_meta.dart';

/// Metadata for a collection resource (like OGC API collection).
///
/// The [id] of the collection can be used as a path segment in URLs.
class OGCCollectionMeta extends CollectionMeta {
  /// Create a metadata instance for a collection resource.
  const OGCCollectionMeta({
    required super.id,
    required super.title,
    super.description,
    super.attribution,
    required super.links,
    super.extent,
    this.itemType = 'feature',
    this.crs = const [
      'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
    ],
    this.storageCrs,
    this.storageCrsCoordinateEpoch,
  });

  /// *An indicator about the type of the items in the collection.*
  ///
  /// The default type is `feature`.
  final String itemType;

  /// Supported CRS identifiers for this collection.
  ///
  /// The
  /// `OGC API - Features - Part 2: Coordinate Reference Systems by Reference`
  /// standard (and early drafts of `OGC API - Common - Part 3: CRS`) allow
  /// providing a global `crs` list for all collections, and collection specific
  /// `crs` lists for each collection. This [crs] property provides a combined
  /// result of coordinate reference systems this collection actually supports
  /// from global and collection specific crs ids.
  ///
  /// The default list contains only WGS84
  /// (`http://www.opengis.net/def/crs/OGC/1.3/CRS84`).
  final Iterable<String> crs;

  /// A coordinate reference system (that is included in [crs] too)
  /// *that may be used to retrieve features from a collection without the need*
  /// *to apply a CRS transformation*.
  final String? storageCrs;

  /// *A point in time at which coordinates in the spatial feature collection*
  /// *are referenced to the dynamic coordinate reference system in*
  /// *[storageCrs]*.
  ///
  /// A value is a decimal year in the Gregorian calendar.
  final num? storageCrsCoordinateEpoch;

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        attribution,
        links,
        extent,
        itemType,
        crs,
        storageCrs,
        storageCrsCoordinateEpoch,
      ];
}
