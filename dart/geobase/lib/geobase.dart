// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geospatial coordinates, projections and data writers (GeoJSON, WKT).
///
/// Key features:
/// * enums for geospatial coordinate and geometry types
/// * *geographic* positions and bounding boxes (longitude-latitude-elevation)
/// * *projected* positions and bounding boxes (cartesian XYZ)
/// * coordinate transformations and projections (initial support)
/// * tiling schemes and tile matrix sets (web mercator)
/// * temporal data structures (instant, interval)
/// * geospatial data writers for features, geometries, coordinates, properties:
///   * supported formats: [GeoJSON](https://geojson.org/)
/// * geospatial data writers for geometries and coordinates:
///   * supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
///
/// Usage: import `package:geobase/geobase.dart`
library geobase;

export 'src/codes/coords.dart';
export 'src/codes/geom.dart';
export 'src/constants/screen_ppi.dart';
export 'src/coordinates/base.dart';
export 'src/coordinates/geographic.dart';
export 'src/coordinates/projected.dart';
export 'src/coordinates/projection.dart';
export 'src/coordinates/scalable.dart';
export 'src/geodesy/spherical.dart';
export 'src/meta/extent.dart';
export 'src/meta/time.dart';
export 'src/projections/mercator.dart';
export 'src/tiling/convert.dart';
export 'src/tiling/tilematrix.dart';
export 'src/transforms/basic.dart';
export 'src/vector/encode.dart';
export 'src/vector/formats.dart';
