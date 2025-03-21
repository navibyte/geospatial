// Copyright (c) 2020-2024 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:geobase/common.dart';

import '/src/core/base/collection_meta.dart';
import '/src/utils/object_utils.dart';

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
      CoordRefSys.CRS84,
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
  /// The default list contains only WGS84 longitude/latitude
  /// (`http://www.opengis.net/def/crs/OGC/1.3/CRS84`).
  final Iterable<CoordRefSys> crs;

  /// A coordinate reference system (that is included in [crs] too)
  /// *that may be used to retrieve features from a collection without the need*
  /// *to apply a CRS transformation*.
  final CoordRefSys? storageCrs;

  /// *A point in time at which coordinates in the spatial feature collection*
  /// *are referenced to the dynamic coordinate reference system in*
  /// *[storageCrs]*.
  ///
  /// A value is a decimal year in the Gregorian calendar.
  final num? storageCrsCoordinateEpoch;

  @override
  String toString() {
    return '${super.toString()};$itemType;'
        'listToString($crs);$storageCrs;$storageCrsCoordinateEpoch';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OGCCollectionMeta &&
          super == other &&
          itemType == other.itemType &&
          testIterableEquality(crs, other.crs) &&
          storageCrs == other.storageCrs &&
          storageCrsCoordinateEpoch == other.storageCrsCoordinateEpoch);

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        itemType,
        Object.hashAll(crs),
        storageCrs,
        storageCrsCoordinateEpoch,
      );
}
