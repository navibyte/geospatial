// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/coordinates/geographic.dart';
import '/src/meta/time.dart';

import 'spatial_extent.dart';
import 'temporal_extent.dart';

// NOTE: generalize => GeoExtent extends DataExtent (spatial extents with Box)?

/// A geospatial extent with [spatial] and optional [temporal] parts.
@immutable
class GeoExtent {
  final SpatialExtent<GeoBox> _spatial;
  final TemporalExtent? _temporal;

  /// A geospatial extent with [spatial] and optional [temporal] parts.
  const GeoExtent({
    required SpatialExtent<GeoBox> spatial,
    TemporalExtent? temporal,
  })  : _spatial = spatial,
        _temporal = temporal;

  /// A geospatial extent of one [bbox] and optional [interval].
  ///
  /// Coordinate reference system can be specified by [crs] and temporal
  /// reference system by [trs].
  GeoExtent.single({
    required GeoBox bbox,
    Interval? interval,
    String crs = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
    String trs = 'http://www.opengis.net/def/uom/ISO-8601/0/Gregorian',
  })  : _spatial = SpatialExtent<GeoBox>.single(bbox, crs: crs),
        _temporal =
            interval != null ? TemporalExtent.single(interval, trs: trs) : null;

  /// A geospatial extent of [boxes] and optional [intervals].
  ///
  /// Coordinate reference system can be specified by [crs] and temporal
  /// reference system by [trs].
  GeoExtent.multi({
    required Iterable<GeoBox> boxes,
    Iterable<Interval>? intervals,
    String crs = 'http://www.opengis.net/def/crs/OGC/1.3/CRS84',
    String trs = 'http://www.opengis.net/def/uom/ISO-8601/0/Gregorian',
  })  : _spatial = SpatialExtent<GeoBox>.multi(boxes, crs: crs),
        _temporal = intervals != null
            ? TemporalExtent.multi(intervals, trs: trs)
            : null;

  /// The spatial extent with bounding boxes in geographic coordinates.
  SpatialExtent<GeoBox> get spatial => _spatial;

  /// An optional temporal extent with time intervals.
  TemporalExtent? get temporal => _temporal;

  @override
  String toString() {
    final buf = StringBuffer()
      ..write('[')
      ..write(spatial)
      ..write(']');
    if (temporal != null) {
      buf
        ..write(',[')
        ..write(temporal)
        ..write(']');
    }
    return buf.toString();
  }

  @override
  bool operator ==(Object other) =>
      other is GeoExtent &&
      spatial == other.spatial &&
      temporal == other.temporal;

  @override
  int get hashCode => Object.hash(spatial, temporal);
}
