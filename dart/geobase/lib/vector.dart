// Copyright (c) 2020-2023 Navibyte (https://navibyte.com). All rights reserved.
// Use of this source code is governed by a “BSD-3-Clause”-style license that is
// specified in the LICENSE file.
//
// Docs: https://github.com/navibyte/geospatial

/// Text and binary formats for vector data (features, geometries, coordinates).
///
/// Key features:
/// * text format encoders for features, geometries, coordinates, properties:
///   * supported formats: [GeoJSON](https://geojson.org/)
/// * text format encoders for geometries and coordinates:
///   * supported formats: [WKT](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry)
/// * binary format encoders and decoders for geometries:
///   * supported formats: [WKB](https://en.wikipedia.org/wiki/Well-known_text_representation_of_geometry#Well-known_binary)
///
/// This libary exports a subset of `package:geobase/geobase.dart`.
///
/// Usage: import `package:geobase/vector.dart`
library vector;

export 'src/codes/geom.dart';
export 'src/vector/content.dart';
export 'src/vector/encoding.dart';
export 'src/vector/formats.dart';
