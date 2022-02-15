// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Geospatial data (features, geometries, coordinates) writers (GeoJSON, WKT).
///
/// Key features:
/// * enums for geospatial coordinate and geometry types
/// * *geographic* positions and bounding boxes (longitude-latitude-elevation)
/// * *projected* positions and bounding boxes (cartesian XYZ)
/// * geospatial data writers for features, geometries, coordinates, properties:
///   * supported formats: [GeoJSON](https://geojson.org/)
/// * geospatial data writers for geometries and coordinates:
///   * supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
///
/// Usage: import `package:geobase/geobase.dart`
library geobase;

export 'src/base/codes.dart';
export 'src/base/coordinates.dart';
export 'src/base/spatial.dart';
export 'src/encode/base.dart';
export 'src/encode/coordinates.dart';
export 'src/encode/features.dart';
export 'src/encode/geometry.dart';
export 'src/formats/geojson.dart';
export 'src/formats/wkt.dart';
export 'src/projections/wgs84.dart';
export 'src/transforms/basic.dart';
