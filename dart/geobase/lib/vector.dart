// Copyright (c) 2020-2022 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Data writers for geospatial vector data (features, geometries, coordinates).
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Key features:
/// * geospatial data writers for features, geometries, coordinates, properties:
///   * supported formats: [GeoJSON](https://geojson.org/)
/// * geospatial data writers for geometries and coordinates:
///   * supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
///
/// Usage: import `package:geobase/vector.dart`
library vector;

export 'src/codes/geom.dart';
export 'src/vector/content.dart';
export 'src/vector/encode.dart';
export 'src/vector/formats.dart';
