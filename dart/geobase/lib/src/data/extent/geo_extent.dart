// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

import 'package:meta/meta.dart';

import '/src/base/coordinates.dart';

import 'spatial_extent.dart';
import 'temporal_extent.dart';

// todo: generalize => GeoExtent extends DataExtent (spatial extents with Box)?

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
